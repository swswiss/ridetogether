class Event < ApplicationRecord
  belongs_to :group
  belongs_to :user

  validates :title, presence: true
  validates :ride_type, presence: true
  validates :date, presence: true
  validates :time, presence: true
  validates :start_location, presence: true
  validates :regime, presence: true
  validates :distance_km, presence: true
  validates :average_speed_kmh, presence: true

  validates :ride_type,
            inclusion: {
              in: %w[MTB Cursieră Plimbare Gravel]
            }

  validates :regime,
            inclusion: {
              in: %w[no_drop drop]
            }
end