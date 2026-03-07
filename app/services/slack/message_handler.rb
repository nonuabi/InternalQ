module Slack
  class MessageHandler
    def self.call(integration:, event:, thread_ts:)
      text = event["text"]
      channel = event["channel"]
      question = sanitize(text)

      unless Usage::LimitChecker.within_limit?(organization_id: integration.organization_id)
        post_limit_message(integration: integration, channel: channel, thread_ts: thread_ts)
        return
      end

      begin
        result = Qa::Answer.call(organization_id: integration.organization_id, question: question, source: "slack")
        answer_text = result[:answer]
      rescue StandardError => e
        Rails.logger.error "Qa::Answer failed for Slack message: #{e.message}"
        answer_text = "Sorry, I couldn't answer that right now. Please try again in a moment."
      end

      begin
        Slack::Client.post_message(
          token: integration.bot_token,
          channel: channel,
          text: answer_text,
          thread_ts: thread_ts
        )
      rescue StandardError => e
        Rails.logger.error "Slack::Client.post_message failed: #{e.message}"
      end
    end

    def self.post_limit_message(integration:, channel:, thread_ts: nil)
      Slack::Client.post_message(
        token: integration.bot_token,
        channel: channel,
        text: "You've reached your monthly question limit. Please try again next month or contact your admin for more information.",
        thread_ts: thread_ts
      )
    rescue StandardError => e
      Rails.logger.error "Slack::Client.post_message (limit) failed: #{e.message}"
    end

    def self.sanitize(text)
      text.gsub(/<@[^>]+>/, "").strip
    end
  end
end
