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
end