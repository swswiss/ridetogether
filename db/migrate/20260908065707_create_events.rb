class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.references :group, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.string :title, null: false
      t.string :ride_type, null: false

      t.date :date, null: false
      t.time :time, null: false

      t.string :start_location, null: false

      t.decimal :distance_km, precision: 6, scale: 2
      t.decimal :average_speed_kmh, precision: 5, scale: 2

      t.string :regime, null: false, default: "no_drop"

      t.text :description

      t.timestamps
    end

    add_index :events, [:group_id, :date, :time]
  end
end
