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
      return head :ok if event["bot_id"].present?
      return head :ok unless event["type"] == "app_mention"

      integration = Integration.find_by(provider: "slack", workspace_id: payload["team_id"])
      unless integration
        return head :not_found
      end

      Slack::MessageHandler.call(integration: integration, event: event)
      head :ok
    end
  end
end
