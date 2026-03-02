module Slack
  class MessageHandler
    def self.call(integration:, event:)
      text = event["text"]
      channel = event["channel"]
      question = sanitize(text)

      begin
        result = Qa::Answer.call(organization_id: integration.organization_id, question: question)
        answer_text = result[:answer]
      rescue StandardError => e
        Rails.logger.error "Qa::Answer failed for Slack message: #{e.message}"
        answer_text = "Sorry, I couldn't answer that right now. Please try again in a moment."
      end

      begin
        Slack::Client.post_message(
          token: integration.bot_token,
          channel: channel,
          text: answer_text
        )
      rescue StandardError => e
        Rails.logger.error "Slack::Client.post_message failed: #{e.message}"
      end
    end

    def self.sanitize(text)
      text.gsub(/<@[^>]+>/, "").strip
    end
  end
end
