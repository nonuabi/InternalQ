class CreateUnansweredQuestions < ActiveRecord::Migration[7.1]
  def change
    create_table :unanswered_questions do |t|
      t.references :organization, null: false, foreign_key: true
      t.text :question, null: false

      t.timestamps
    end
  end
end
