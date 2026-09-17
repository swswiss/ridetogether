class AddPostRepliesCountToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :post_replies_count, :integer, null: false, default: 0
  end
end
