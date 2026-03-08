module Slack
  class MessageHandler
    def initialize(integration:, event:, thread_ts: nil)
      @integration = integration
      @text = event["text"]
      @channel = event["channel"]
      @thread_ts = thread_ts
    end

    attr_reader :integration, :text, :channel, :thread_ts, :answer

    def call
      question = sanitize(text)
      if question.blank?
        Rails.logger.error "Slack::MessageHandler: Question is blank"
        post_slack_message(text: "Sorry, I couldn't answer that right now. Please try again in a moment.")
        return
      end

      unless Usage::LimitChecker.within_limit?(organization_id: integration.organization_id)
        post_slack_message(text: "You've reached your monthly question limit. Please try again next month or contact your admin for more information.")
        return
      end

      begin
        result = Qa::Answer.call(organization_id: integration.organization_id, question: question, source: "slack")
        @answer = result[:answer]
      rescue StandardError => e
        Rails.logger.error "Qa::Answer failed for Slack message: #{e.message}"
        @answer = "Sorry, I couldn't answer that right now. Please try again in a moment."
      end

      post_slack_message(text: @answer)
    rescue StandardError => e
      Rails.logger.error "Slack::MessageHandler failed: #{e.message}\n#{e.backtrace.first(5).join("\n")}"
      post_slack_message(text: "Sorry, I couldn't answer that right now. Please try again in a moment.")
    end

    private

    def sanitize(text)
      text.gsub(/<@[^>]+>/, "").strip
    end

    def post_slack_message(text:)
      Slack::Client.post_message(
        token: integration.bot_token,
        channel: channel,
        text: text,
        thread_ts: thread_ts
      )
    end
  end
end
