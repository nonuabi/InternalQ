module Slack
  class MessageHandler
    def initialize(integration:, event:, thread_ts: nil)
      @integration = integration
      @text = event["text"]
      @channel = event["channel"]
      @thread_ts = thread_ts
    end

    attr_reader :integration, :text, :channel, :thread_ts, :answer, :sources

    def call
      question = sanitize(text)
      if question.blank?
        Rails.logger.error "Slack::MessageHandler: Question is blank"
        post_slack_message(text: "Sorry, I couldn't answer that right now. Please try again in a moment.")
        return
      end

      if question.length > 1_000
        post_slack_message(text: "Your question is too long (max 1,000 characters). Please shorten it and try again.")
        return
      end

      unless Usage::LimitChecker.within_limit?(organization_id: integration.organization_id)
        app_url = ENV.fetch("APP_HOST", "https://internalq.zezlab.com")
        post_slack_message(text: "Your team has reached its monthly question limit. Upgrade your plan to keep going → #{app_url}/pricing")
        return
      end

      begin
        result = Qa::Answer.call(organization_id: integration.organization_id, question: question, source: "slack")
        @answer = to_slack_mrkdwn(result[:answer])
        @sources = result[:sources] || []
      rescue StandardError => e
        Rails.logger.error "Qa::Answer failed for Slack message: #{e.message}"
        @answer = "Sorry, I couldn't answer that right now. Please try again in a moment."
        @sources = []
      end

      post_slack_message(text: format_reply(@answer, @sources))
    rescue StandardError => e
      Rails.logger.error "Slack::MessageHandler failed: #{e.message}\n#{e.backtrace.first(5).join("\n")}"
      post_slack_message(text: "Sorry, I couldn't answer that right now. Please try again in a moment.")
    end

    private

    def sanitize(text)
      text.gsub(/<@[^>]+>/, "").strip
    end

    def to_slack_mrkdwn(text)
      text.to_s.gsub(/\*\*(.*?)\*\*/, '*\1*')
    end

    def format_reply(answer, sources)
      return answer if sources.blank?

      app_url = ENV.fetch("APP_HOST", "https://internalq.zezlab.com")
      source_lines = sources.map { |s|
        "<#{app_url}/documents/#{s[:document_id]}|📄 #{s[:name]}>"
      }.join("\n")
      "#{answer}\n\n_Sources:_\n#{source_lines}"
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
