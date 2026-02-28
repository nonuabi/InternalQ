module Slack
  class OauthController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin!



    def connect
      org_id = current_user.organization.id

      redirect_to(
        "https://slack.com/oauth/v2/authorize?" +
        {
          client_id: ENV["SLACK_CLIENT_ID"],
          scope: bot_scopes,
          redirect_uri: ENV["SLACK_REDIRECT_URI"],
          state: org_id
        }.to_query
      )
    end

    def callback
      auth_code = params[:code]
      org_id = params[:state]

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
      unless data["ok"]
        return redirect_to root_path, alert: "Failed to connect to Slack. Please try again."
      end

      integration = Integration.find_or_initialize_by(organization_id: org_id, provider: "slack")
      integration.update(
        organization_id: org_id,
        workspace_id: data.dig("team", "id"),
        provider: "slack",
        bot_user_id: data["bot_user_id"],
        bot_token: data["access_token"]
      )

      redirect_to root_path, notice: "Slack integration connected successfully."
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
