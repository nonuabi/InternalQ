class AddOrgAndRoleToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :organization, foreign_key: true
    add_column :users, :role, :string, null: false, default: "employee"
  end
end
