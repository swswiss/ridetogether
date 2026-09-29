class CreateEventPhotos < ActiveRecord::Migration[8.1]
  def change
    create_table :event_photos do |t|
      t.references :event, null: false, foreign_key: true
      t.references :user,  null: false, foreign_key: true
      t.string  :cloudinary_public_id, null: false
      t.integer :width
      t.integer :height
  
      t.timestamps
    end
  
    add_index :event_photos, [:event_id, :created_at]
  end
end
