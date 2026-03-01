class IntegrationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!, only: [ :destroy_slack ]

  def index
    @integrations = current_user.organization.integrations
    @slack_integration = @integrations.find { |i| i.provider == "slack" }
  end

  def destroy_slack
    integration = current_user.organization.integrations.find_by(provider: "slack")
    unless integration
      return redirect_to integrations_path, alert: "Slack is not connected."
    end

    if integration.bot_token.present?
      response = Slack::Client.revoke_token(token: integration.bot_token)
      unless response.code == 200 && response.parsed_response["ok"]
        Rails.logger.warn "Slack auth.revoke failed: #{response.inspect}"
      end
    end

    integration.destroy
    redirect_to integrations_path, notice: "Slack has been disconnected. Your workspace will no longer receive responses from Knowledge Vault."
  end
end
