class Route < ApplicationRecord
  belongs_to :user
  has_many :events, dependent: :nullify

  validates :name, presence: true
  validates :coordinates, presence: true

  validate :has_enough_points
  validate :user_route_limit

  private

  def has_enough_points
    if coordinates.blank? || coordinates.size < 2
      errors.add(:coordinates, "Desenează un traseu cu cel puțin 2 puncte.")
    end
  end

  def user_route_limit
    return unless user&.role == "user"
    return unless user.routes.where.not(id: id).count >= 2

    errors.add(:base, "Poți avea maximum 2 trasee.")
  end
end
