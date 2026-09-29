# ═══════════════════════════════════════════════════════
# MODELUL — acum suportă poze ȘI video
# app/models/event_photo.rb  (păstrăm numele, dar ține și video)
# ═══════════════════════════════════════════════════════
#
# Adăugăm:
#  - resource_type: "image" sau "video" (Cloudinary îl returnează)
#  - validare: max 10 fișiere per event
#
# MIGRARE nouă (adaugă coloana resource_type):
#   bin/rails g migration AddResourceTypeToEventPhotos resource_type:string
#   apoi în migrare pune default "image":
#     add_column :event_photos, :resource_type, :string, null: false, default: "image"
#   bin/rails db:migrate

class EventPhoto < ApplicationRecord
  belongs_to :event
  belongs_to :user

  MAX_PER_EVENT = 10

  validates :cloudinary_public_id, presence: true
  validates :resource_type, inclusion: { in: %w[image video] }

  # limită: max 10 fișiere per event (poze + video la un loc)
  validate :event_within_limit, on: :create

  after_destroy_commit :enqueue_cloudinary_cleanup

  def video?
    resource_type == "video"
  end

  # URL pentru afișare, optimizat, prin CDN.
  # size: :thumb (grilă) sau :large (lightbox)
  def url(size: :thumb)
    dims =
      case size
      when :thumb then { width: 300, height: 300, crop: :fill, gravity: :auto }
      when :large then { width: 1400, crop: :limit }
      else {}
      end

    Cloudinary::Utils.cloudinary_url(
      cloudinary_public_id,
      dims.merge(
        resource_type: resource_type,        # important pt video
        fetch_format: :auto,
        quality: :auto,
        secure: true
      )
    )
  end

  # pentru video: un poster (thumbnail) generat din primul cadru
  def poster_url
    Cloudinary::Utils.cloudinary_url(
      cloudinary_public_id,
      resource_type: "video",
      format: "jpg",                          # extrage un cadru ca imagine
      width: 300, height: 300, crop: :fill, gravity: :auto,
      quality: :auto, secure: true
    )
  end

  private

  def event_within_limit
    return unless event

    if event.event_photos.count >= MAX_PER_EVENT
      errors.add(:base, "Ai atins limita de #{MAX_PER_EVENT} fișiere pentru această tură.")
    end
  end

  def enqueue_cloudinary_cleanup
    CloudinaryCleanupJob.perform_later(cloudinary_public_id, resource_type)
  end
end
