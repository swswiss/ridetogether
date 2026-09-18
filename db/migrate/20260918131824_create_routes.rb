class CreateRoutes < ActiveRecord::Migration[8.1]
  def change
    create_table :routes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.jsonb :coordinates, null: false, default: []
      t.decimal :distance_km, precision: 6, scale: 2, default: 0

      t.timestamps
    end
  end
end
