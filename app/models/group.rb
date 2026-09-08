class Group < ApplicationRecord
  belongs_to :user

  has_many :group_memberships,
           dependent: :destroy
  has_many :members,
           through: :group_memberships,
           source: :user

  has_many :active_memberships,
            -> { where(status: "active") },
            class_name: "GroupMembership"
  has_many :active_members,
           through: :active_memberships,
           source: :user

  has_many :events,
           dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :ride_types, presence: true
  validates :city, presence: true

  before_validation :generate_slug, on: :create

  private

  def generate_slug
    self.slug = name.parameterize if slug.blank?
  end
end
