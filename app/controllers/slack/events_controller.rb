module Slack
  class EventsController < ApplicationController
    skip_before_action :verify_authenticity_token

    def receive
      payload = JSON.parse(request.body.read)
      Rails.logger.debug "Slack event payload: #{payload.inspect}"
      puts "Slack event payload: #{payload.inspect}"

      if payload["type"] == "url_verification"
        return render json: { challenge: payload["challenge"] }, status: :ok
      end

      unless payload["type"] == "event_callback"
        return head :ok
      end

      event = payload["event"]
      # Only handle app_mention and message (skip bot messages to avoid loops)
      return head :ok if event["bot_id"].present?
      return head :ok unless %w[app_mention message].include?(event["type"])

      integration = Integration.find_by(provider: "slack", workspace_id: payload["team_id"])
      unless integration
        return head :not_found
      end

      Slack::MessageHandler.call(integration: integration, event: event)
      head :ok
    end
  end
end
