module Slack
  class AppHomeWelcomeJob < ApplicationJob
    queue_as :default

    WELCOME_MESSAGE = <<~MSG.strip
      👋 Hey there! I'm *InternalQ* — your team's AI-powered knowledge assistant.

      Here's how to get the most out of me:
      • *Ask me anything* about your team's internal docs and knowledge base
      • Mention me in any channel with `@InternalQ` followed by your question
      • Or just message me directly right here

      I'll do my best to find the answer and point you to the source. Give it a try — what do you want to know? 🔍
    MSG

    def perform(integration:, user_id:)
      # Only send the welcome message once per user per workspace.
      cache_key = "slack_welcome_sent:#{integration.workspace_id}:#{user_id}"
      return if Rails.cache.read(cache_key)

      channel_id = Slack::Client.open_dm(token: integration.bot_token, user_id: user_id)
      return unless channel_id

      Slack::Client.post_message(
        token: integration.bot_token,
        channel: channel_id,
        text: WELCOME_MESSAGE
      )

      Rails.cache.write(cache_key, "1", expires_in: 1.year)
    rescue StandardError => e
      Rails.logger.error "Slack::AppHomeWelcomeJob failed for user #{user_id}: #{e.message}"
    end
  end
end
