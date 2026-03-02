module Slack
  class OauthController < ApplicationController
    before_action :authenticate_user!, except: [ :install ]
    before_action :require_admin!, only: [ :connect ]
    skip_before_action :verify_authenticity_token, only: [ :callback ]

    # Direct install URL for Slack marketplace: starts OAuth if signed in (admin), else sends to sign up then connect.
    def install
      if user_signed_in?
        if current_user.admin?
          redirect_to slack_connect_path
        else
          redirect_to integrations_path, notice: "Only an admin can connect Slack. Your workspace may already be connected."
        end
      else
        session["user_return_to"] = slack_connect_path
        redirect_to new_user_registration_path
      end
    end

    def connect
      org_id = current_user.organization.id

      redirect_to(
        "https://slack.com/oauth/v2/authorize?" +
        {
          client_id: ENV["SLACK_CLIENT_ID"],
          scope: bot_scopes,
          redirect_uri: ENV["SLACK_REDIRECT_URI"],
          state: org_id
        }.to_query,
        allow_other_host: true
      )
    end

    def callback
      auth_code = params[:code]
      org_id = params[:state]

      unless auth_code.present? && org_id.present?
        return redirect_to root_path, alert: "Invalid Slack callback. Please try connecting again from Integrations."
      end

      # Ensure state matches current user's org (user must be the one who started the flow).
      if current_user.organization_id != org_id.to_i
        return redirect_to integrations_path, alert: "Session mismatch. Please try connecting Slack again."
      end

      response = HTTParty.post(
        "https://slack.com/api/oauth.v2.access",
        body: {
          client_id: ENV["SLACK_CLIENT_ID"],
          client_secret: ENV["SLACK_CLIENT_SECRET"],
          code: auth_code,
          redirect_uri: ENV["SLACK_REDIRECT_URI"]
        }
      )

      data = response.parsed_response
      Rails.logger.debug "Slack OAuth callback response: #{data.inspect}"
      puts "Slack OAuth callback response: #{data.inspect}"
      unless data["ok"]
        return redirect_to integrations_path, alert: "Failed to connect to Slack. Please try again."
      end

      workspace_id = data.dig("team", "id")
      existing_integration = Integration.find_by(provider: "slack", workspace_id: workspace_id)

      # Workspace already connected to another organization → add this user to that org (same-team member).
      if existing_integration.present? && existing_integration.organization_id != org_id.to_i
        target_org = existing_integration.organization
        current_user.update!(organization_id: target_org.id, role: "employee")

        # Remove empty placeholder org if this user was the only member and had no data.
        old_org = Organization.find_by(id: org_id)
        if old_org && old_org.users.count == 0 && old_org.documents.count == 0
          old_org.destroy
        end

        return redirect_to integrations_path,
          notice: "This workspace is already connected. You've been added to your team's organization."
      end

      integration = Integration.find_or_initialize_by(organization_id: org_id, provider: "slack")
      integration.update(
        organization_id: org_id,
        workspace_id: workspace_id,
        provider: "slack",
        bot_user_id: data["bot_user_id"],
        bot_token: data["access_token"],
        status: "connected"
      )

      # Use Slack workspace name for the organization when first connecting or reconnecting.
      team_name = data.dig("team", "name")
      if team_name.present?
        org = integration.organization
        org.update!(name: team_name) unless org.name == team_name
      end

      redirect_to integrations_path, notice: "Slack integration connected successfully."
    end

    private

    def bot_scopes
      %w[
        app_mentions:read
        chat:write
        chat:write.public
        channels:history
        groups:history
        im:history
        mpim:history
        channels:read
      ].join(",")
    end
  end
end
