class EventParticipation < ApplicationRecord
  belongs_to :event
  belongs_to :user

  STATUSES = %w[going maybe not_going].freeze

  validates :status,
            inclusion: { in: STATUSES }

  validates :user_id,
            uniqueness: { scope: :event_id }
end