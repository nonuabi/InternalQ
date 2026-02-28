module Slack
  class MessageHandler
    def self.call(integration:, event:)
      text = event["text"]
      channel = event["channel"]

      # answer = Qa::Answer.call(user: integration.user, question: sanitize(text))
      # Slack::Client.post_message(token: integration.bot_token, channel: channel, text: answer)

      # For testing: respond immediately without waiting for Qa::Answer
      Slack::Client.post_message(
        token: integration.bot_token,
        channel: channel,
        text: "Got it! You said: #{sanitize(text)}"
      )
    end

    def self.sanitize(text)
      text.gsub(/<@[^>]+>/, "").strip
    end
  end
end
