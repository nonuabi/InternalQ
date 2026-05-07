module Slack
  class EventsController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :verify_slack_request

    def receive
      payload = JSON.parse(request.raw_post)
      if payload["type"] == "url_verification"
        return render json: { challenge: payload["challenge"] }, status: :ok
      end

      unless payload["type"] == "event_callback"
        return head :ok
      end

      event = payload["event"] || {}

      # Ignore events coming from bots (including ourselves).
      return head :ok if event["bot_id"].present?

      # Handle app uninstallation or token revocation to keep integration state in sync.
      case event["type"]
      when "app_uninstalled", "tokens_revoked"
        integration = Integration.find_by(provider: "slack", workspace_id: payload["team_id"])
        if integration
          integration.update(status: "disconnected", bot_token: nil)
        end
        return head :ok
      end

      # We process:
      # - app_mention events in channels
      # - direct messages to the bot (message events in IM channels)
      # - message events in threads
      is_app_mention = event["type"] == "app_mention"
      is_direct_message = event["type"] == "message" && event["channel_type"] == "im" && event["subtype"].blank?
      is_thread_message = event["type"] == "message" && event["channel_type"] == "channel" && event["thread_ts"].present?
      return head :ok unless is_app_mention || is_direct_message || is_thread_message

      integration = Integration.find_by(provider: "slack", workspace_id: payload["team_id"])
      unless integration
        return head :not_found
      end

      # Respond to Slack immediately (< 3s) so it doesn't retry and send duplicate events.
      # Process the answer in a thread and post when ready.
      # Always reply in thread: use thread_ts if already in a thread, else use message ts to start a new thread.
      thread_ts = event["thread_ts"] || event["ts"]
      # TODO: in future, we should use a more robust solution when we have money to setup a separate worker. for now, this is a quick fix.
      event_id = payload["event_id"]
      if already_processing?(event_id)
        return head :ok
      end

      unless ActiveModel::Type::Boolean.new.cast(ENV.fetch("RUN_JOBS_INLINE", "false"))
        Slack::MessageHandlerJob.perform_later(integration: integration, event: event, thread_ts: thread_ts)
      else
        Thread.new do
          begin
            Slack::MessageHandler.new(integration: integration, event: event, thread_ts: thread_ts).call
          rescue StandardError => e
            Rails.logger.error "Slack::MessageHandler failed: #{e.message}\n#{e.backtrace.first(5).join("\n")}"
          end
        end
      end

      head :ok
    end

    private

    SLACK_EVENT_MUTEX = Mutex.new

    def verify_slack_request
      signing_secret = ENV["SLACK_SIGNING_SECRET"]
      timestamp      = request.headers["X-Slack-Request-Timestamp"]
      signature      = request.headers["X-Slack-Signature"]

      if signing_secret.blank? || timestamp.blank? || signature.blank?
        Rails.logger.warn "Slack request missing signing data; rejecting."
        return head :unauthorized
      end

      # Prevent replay attacks (older than 5 minutes).
      if (Time.now.to_i - timestamp.to_i).abs > 5.minutes.to_i
        Rails.logger.warn "Slack request timestamp too old; rejecting."
        return head :unauthorized
      end

      sig_basestring = "v0:#{timestamp}:#{request.raw_post}"
      computed = "v0=" + OpenSSL::HMAC.hexdigest("SHA256", signing_secret, sig_basestring)

      unless ActiveSupport::SecurityUtils.secure_compare(computed, signature)
        Rails.logger.warn "Slack signature verification failed; rejecting."
        head :unauthorized
      end
    end

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
