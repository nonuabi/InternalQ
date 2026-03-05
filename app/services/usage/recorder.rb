# frozen_string_literal: true

module Usage
  class Recorder
    def self.record(organization_id:, source: "web")
      QuestionUsage.create!(
        organization_id: organization_id,
        source: source.to_s
      )
    rescue StandardError => e
      Rails.logger.error "Usage::Recorder failed: #{e.message}"
    end
  end
end
