class CreateGroupMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :group_memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true

      t.string :role, null: false, default: "member"
      t.string :status, null: false, default: "pending"

      t.timestamps
    end

    add_index :group_memberships,
              [:user_id, :group_id],
              unique: true
  end
end
