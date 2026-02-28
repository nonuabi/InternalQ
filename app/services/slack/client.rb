module Slack
  class Client
    include HTTParty
    base_uri "https://slack.com/api"

    def self.post_message(token:, channel:, text:)
      post(
        "/chat.postMessage",
        headers: {
          "Authorization" => "Bearer #{token}",
          "Content-Type" => "application/json; charset=utf-8"
        },
        body: { channel: channel, text: text }.to_json
      )
    end
  end
end
