class AddUniqueIndexToEvents < ActiveRecord::Migration[8.1]
  def change
    add_index :events,
              [:group_id, :user_id, :date],
              unique: true,
              name: "index_events_on_group_user_date_unique"
  end
end
