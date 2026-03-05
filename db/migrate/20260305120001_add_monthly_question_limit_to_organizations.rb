# frozen_string_literal: true

class AddMonthlyQuestionLimitToOrganizations < ActiveRecord::Migration[8.0]
  def change
    add_column :organizations, :monthly_question_limit, :integer, null: true, comment: "Max questions per calendar month; null = use default or unlimited"
  end
end
