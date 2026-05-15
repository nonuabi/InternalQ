class Organization < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :integrations, dependent: :destroy
  has_many :question_usages, dependent: :destroy
  has_many :unanswered_questions, dependent: :destroy

  validates :name, presence: true
  validates :plan, inclusion: { in: PlanCaps::NAMES }

  # Monthly question cap: manual override on the record takes precedence over plan default.
  # Set monthly_question_limit to a positive integer for custom/enterprise overrides.
  def question_limit
    monthly_question_limit.presence || PlanCaps::TIERS.dig(plan, :questions)
  end

  def member_limit
    PlanCaps::TIERS.dig(plan, :members)
  end

  def at_member_limit?
    users.count >= member_limit
  end
end
