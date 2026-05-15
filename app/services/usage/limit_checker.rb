# frozen_string_literal: true

module Usage
  # Checks whether an organization is within its monthly question cap.
  # The cap is resolved by Organization#question_limit, which reads from
  # PlanCaps (plan tier) with an optional per-org override field.
  class LimitChecker
    def self.within_limit?(organization_id:)
      org = Organization.find_by(id: organization_id)
      return true unless org

      limit = org.question_limit
      return true if limit.nil? || limit <= 0

      usage_this_month(organization_id) < limit
    end

    def self.remaining(organization_id:)
      org = Organization.find_by(id: organization_id)
      return nil unless org

      limit = org.question_limit
      return nil if limit.nil? || limit <= 0

      [ limit - usage_this_month(organization_id), 0 ].max
    end

    # Returns { used: Integer, limit: Integer | nil } for display on the Team page.
    def self.usage_for_display(organization_id:)
      org = Organization.find_by(id: organization_id)
      return { used: 0, limit: nil } unless org

      limit = org.question_limit
      limit = nil if limit.present? && limit <= 0
      { used: usage_this_month(organization_id), limit: limit }
    end

    def self.usage_this_month(organization_id)
      QuestionUsage.where(organization_id: organization_id)
                   .where(created_at: Time.current.beginning_of_month..)
                   .count
    end
    private_class_method :usage_this_month
  end
end
