class Group < ApplicationRecord
  belongs_to :user

  has_many :group_memberships,
           dependent: :destroy

  has_many :members,
           through: :group_memberships,
           source: :user

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
