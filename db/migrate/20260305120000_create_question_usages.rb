# frozen_string_literal: true

class CreateQuestionUsages < ActiveRecord::Migration[8.0]
  def change
    create_table :question_usages do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :source, null: false, default: "web" # 'web' | 'slack'

      t.timestamps
    end

    add_index :question_usages, [ :organization_id, :created_at ], name: "index_question_usages_on_org_and_created_at"
  end
end
