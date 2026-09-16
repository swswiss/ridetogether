class CreatePostReplies < ActiveRecord::Migration[8.1]
  def change
    create_table :post_replies do |t|
      t.references :post, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false

      t.timestamps
    end
  end
end
