class GroupMembership < ApplicationRecord
  belongs_to :user
  belongs_to :group

  validates :role,
            inclusion: {
              in: %w[member moderator admin]
            }

  validates :status,
            inclusion: {
              in: %w[pending active rejected banned]
            }

  def pending?
    status == "pending"
  end

  def active?
    status == "active"
  end

  def rejected?
    status == "rejected"
  end

  def banned?
    status == "banned"
  end

  def admin?
    role == "admin"
  end

  def moderator?
    role == "moderator"
  end

  def member?
    role == "member"
  end
end