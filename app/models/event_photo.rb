class EventPhoto < ApplicationRecord
  belongs_to :event
  belongs_to :user

  validates :cloudinary_public_id, presence: true

  # după ștergerea din DB, șterge poza și de pe Cloudinary (în fundal)
  after_destroy_commit :enqueue_cloudinary_cleanup

  # URL pentru afișare, la dimensiunea cerută, optimizat automat.
  # size: :thumb (grilă) sau :large (lightbox)
  def url(size: :thumb)
    transformation =
      case size
      when :thumb then { width: 400, height: 400, crop: :fill, gravity: :auto }
      when :large then { width: 1400, crop: :limit }
      else {}
      end

    Cloudinary::Utils.cloudinary_url(
      cloudinary_public_id,
      transformation.merge(fetch_format: :auto, quality: :auto, secure: true)
    )
  end

  private

  def enqueue_cloudinary_cleanup
    CloudinaryCleanupJob.perform_later(cloudinary_public_id)
  end
end