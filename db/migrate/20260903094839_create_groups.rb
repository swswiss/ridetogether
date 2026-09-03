class CreateGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :groups do |t|
      t.references :user, null: false, foreign_key: true
  
      t.string :name, null: false
      t.string :slug, null: false
      t.string :city, null: false
      t.text :description
  
      t.boolean :join_requires_approval, null: false, default: true
      t.string :ride_types, array: true, default: []
      t.boolean :public, null: false, default: true
  
      t.timestamps
    end
  
    add_index :groups, :slug, unique: true
  end
end
