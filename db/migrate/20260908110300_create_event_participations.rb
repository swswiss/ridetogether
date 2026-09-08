class CreateEventParticipations < ActiveRecord::Migration[8.1]
  def change
    create_table :event_participations do |t|
      t.references :event, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false

      t.timestamps
    end

    add_index :event_participations,
              [:event_id, :user_id],
              unique: true
  end
end
