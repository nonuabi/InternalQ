class CreateIntegrations < ActiveRecord::Migration[8.0]
  def change
    create_table :integrations do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :provider, null: false
      t.string :workspace_id, null: false
      t.string :bot_user_id
      t.string :bot_token
      t.string :status

      t.timestamps
    end

    add_index :integrations, [ :provider, :workspace_id ], unique: true
  end
end
