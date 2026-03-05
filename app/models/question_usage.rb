# frozen_string_literal: true

class QuestionUsage < ApplicationRecord
  belongs_to :organization

  validates :source, presence: true, inclusion: { in: %w[web slack] }
end
