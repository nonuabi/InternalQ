# frozen_string_literal: true

# Single source of truth for plan tier caps.
# Upgrade/downgrade is manual (admin sets org.plan directly).
# question_limit: max questions per calendar month
# member_limit:   max users in the organization
module PlanCaps
  TIERS = {
    "free"     => { questions: 50,     members: 2   }.freeze,
    "starter"  => { questions: 500,    members: 10  }.freeze,
    "pro"      => { questions: 3_000,  members: 50  }.freeze,
    "business" => { questions: 15_000, members: 200 }.freeze
  }.freeze

  NAMES = TIERS.keys.freeze
end
