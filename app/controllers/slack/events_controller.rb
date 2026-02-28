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

      # Respond to Slack immediately (< 3s) so it doesn't retry and send duplicate events.
      # Process the answer in a thread and post when ready.
      # TODO: in future, we should use a more robust solution when we have money to setup a separate worker. for now, this is a quick fix.
      event_id = payload["event_id"]
      if already_processing?(event_id)
        return head :ok
      end

      Thread.new do
        begin
          Slack::MessageHandler.call(integration: integration, event: event)
        rescue StandardError => e
          Rails.logger.error "Slack::MessageHandler failed: #{e.message}\n#{e.backtrace.first(5).join("\n")}"
        end
      end

      head :ok
    end

    private

    SLACK_EVENT_MUTEX = Mutex.new

    def already_processing?(event_id)
      key = "slack_event:#{event_id}"
      SLACK_EVENT_MUTEX.synchronize do
        return true if Rails.cache.read(key)
        Rails.cache.write(key, "1", expires_in: 5.minutes)
        false
      end
    end
  end
end
