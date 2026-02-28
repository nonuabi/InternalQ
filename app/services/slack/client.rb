module Slack
  class Client
    include HTTParty
    base_uri "https://slack.com/api"

    debug_output $stdout

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

    # Revoke the bot token on Slack's side so the app is removed from the workspace.
    def self.revoke_token(token:)
      post(
        "/auth.revoke",
        headers: {
          "Authorization" => "Bearer #{token}",
          "Content-Type" => "application/x-www-form-urlencoded"
        },
        body: {}
      )
    end
  end
end
