module Slack
  class EventsController < ApplicationController
    def receive
      payload = JSON.parse(request.body.read)
      Rails.logger.debug "Slack event payload: #{payload.inspect}"
      puts "Slack event payload: #{payload.inspect}"

      if payload["type"] == "url_verification"
        return render json: { challenge: payload["challenge"] }, status: :ok
      end

      if payload["type"] == "event"
        return head :ok
      end

      integration = Integration.find_by(provider: "slack", workspace_id: payload["team_id"])
      unless integration
        return head :not_found
      end

      Slack::MessageHandler.call(integration: integration, event: payload)
      head :ok
    end
  end
end
