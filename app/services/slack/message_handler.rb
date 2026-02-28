module Slack
  class MessageHandler
    def self.call(integration:, event:)
      text = event["text"]
      channel = event["channel"]
      question = sanitize(text)

      result = Qa::Answer.call(user: integration.user, question: question)
      answer_text = result[:answer]
      # answer_text += "\n_Sources: #{result[:sources].map { |s| s[:filename] }.join(', ')}_" if result[:sources].present?

      Slack::Client.post_message(
        token: integration.bot_token,
        channel: channel,
        text: answer_text
      )
    end

    def self.sanitize(text)
      text.gsub(/<@[^>]+>/, "").strip
    end
  end
end
