module Slack
  class MessageHandlerJob < ApplicationJob
    queue_as :default

    def perform(integration:, event:, thread_ts:)
      Slack::MessageHandler.new(integration: integration, event: event, thread_ts: thread_ts).call
    end
  end
end
