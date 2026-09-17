class CreatePostLikes < ActiveRecord::Migration[8.1]
  def change
    create_table :post_likes do |t|
      t.references :post, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :post_likes,
              [:post_id, :user_id],
              unique: true

    add_column :posts,
                :post_likes_count,
                :integer,
                null: false,
                default: 0
  end
end
