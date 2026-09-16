class Post < ApplicationRecord
  belongs_to :event
  belongs_to :user

  validates :body, presence: true

  has_many :post_replies, dependent: :destroy
end
