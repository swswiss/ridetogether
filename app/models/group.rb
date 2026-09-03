class Group < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :ride_types, presence: true

  before_validation :generate_slug, on: :create

  private

  def generate_slug
    self.slug = name.parameterize if slug.blank?
  end
end
