module Slack
  class MessageHandler
    def self.call(integration:, event:)
      text = event["text"]
      channel = event["channel"]


      answer = Qa::Answer.call(user: integration.user, question: sanitize(text))
      Slack::Client.post_message(token: integration.bot_token, channel: channel, text: answer)
    end

    def self.sanitize(text)
      text.gsub(/<@[^>]+>/, "").strip
    end
  end
end
