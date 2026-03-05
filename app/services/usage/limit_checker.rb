# frozen_string_literal: true

module Usage
  # Checks if an organization is within its monthly question limit before calling the LLM.
  # Use DEFAULT_MONTHLY_QUESTION_LIMIT env (integer) for orgs that have no custom limit; 0 or unset = unlimited.
  class LimitChecker
    def self.within_limit?(organization_id:)
      org = Organization.find_by(id: organization_id)
      return true unless org

      limit = effective_limit(org)
      return true if limit.nil? || limit <= 0

      count = QuestionUsage.where(organization_id: organization_id)
                           .where(created_at: Time.current.beginning_of_month..)
                           .count
      count < limit
    end

    def self.remaining(organization_id:)
      org = Organization.find_by(id: organization_id)
      return nil unless org

      limit = effective_limit(org)
      return nil if limit.nil? || limit <= 0

      count = QuestionUsage.where(organization_id: organization_id)
                           .where(created_at: Time.current.beginning_of_month..)
                           .count
      [ limit - count, 0 ].max
    end

    # For display on Team page: { used: count_this_month, limit: effective_limit_or_nil }
    def self.usage_for_display(organization_id:)
      org = Organization.find_by(id: organization_id)
      return { used: 0, limit: nil } unless org

      used = QuestionUsage.where(organization_id: organization_id)
                          .where(created_at: Time.current.beginning_of_month..)
                          .count
      limit = effective_limit(org)
      limit = nil if limit.present? && limit <= 0
      { used: used, limit: limit }
    end

    def self.effective_limit(org)
      return default_limit if org.monthly_question_limit.nil?
      org.monthly_question_limit
    end

    def self.default_limit
      v = ENV["DEFAULT_MONTHLY_QUESTION_LIMIT"].to_s.strip
      return nil if v.blank?
      v.to_i
    end
  end
end
