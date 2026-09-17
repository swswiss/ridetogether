class Post < ApplicationRecord
  belongs_to :event
  belongs_to :user

  validates :body, presence: true

  has_many :post_replies, dependent: :destroy
  has_many :post_likes, dependent: :destroy
  has_many :likers, through: :post_likes, source: :user

  def liked_by?(user)
    post_likes.exists?(user: user)
  end
end
