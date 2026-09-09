class Event < ApplicationRecord
  belongs_to :group
  belongs_to :user

  RIDE_TYPES = %w[MTB Cursieră Plimbare Gravel].freeze

  has_many :event_participations,
           dependent: :destroy

  has_many :participants,
           through: :event_participations,
           source: :user

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

  validates :estimated_duration_minutes,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than: 0
            }

  validates :strava_link,
            format: {
              with: URI::DEFAULT_PARSER.make_regexp(%w[http https])
            },
            allow_blank: true
end