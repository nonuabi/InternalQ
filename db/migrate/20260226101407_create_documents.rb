class CreateDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :documents do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :title
      t.string :status, null: false, default: "uploaded" # uploaded, processing, indexed, failed
      t.text :extracted_text
      t.text :error_message
      t.timestamps
    end
  end
end
