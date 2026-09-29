class AddResourceTypeToEventPhotos < ActiveRecord::Migration[8.1]
  def change
    add_column :event_photos, :resource_type, :string, null: false, default: "image"
  end
end
