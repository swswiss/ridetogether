class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :created_groups,
           class_name: "Group",
           foreign_key: :user_id,
           dependent: :destroy

  validates :role, presence: true
  validates :email_address,
    presence: true,
    uniqueness: true
  validates :name, presence: true
  validates :city, presence: true
  validates :password,
    length: { minimum: 8 },
    allow_nil: true
  validates :password,
    confirmation: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def admin?
    role == "admin"
  end

  def can_create_group?
    admin? || created_groups.count < 2
  end
end
