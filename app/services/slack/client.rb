module Slack
  class Client
    include HTTParty
    base_uri "https://slack.com/api"
    default_timeout 10

    def self.post_message(token:, channel:, text:, thread_ts: nil)
      post(
        "/chat.postMessage",
        headers: {
          "Authorization" => "Bearer #{token}",
          "Content-Type" => "application/json; charset=utf-8"
        },
        body: { channel: channel, text: text }.merge(thread_ts ? { thread_ts: thread_ts } : {}).to_json
      )
    end

    # Open a DM channel with a user and return the channel ID.
    def self.open_dm(token:, user_id:)
      resp = post(
        "/conversations.open",
        headers: {
          "Authorization" => "Bearer #{token}",
          "Content-Type" => "application/json; charset=utf-8"
        },
        body: { users: user_id }.to_json
      )
      resp.parsed_response.dig("channel", "id")
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
