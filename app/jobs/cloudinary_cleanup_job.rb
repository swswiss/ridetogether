class CloudinaryCleanupJob < ApplicationJob
  queue_as :default

  def perform(public_id, resource_type = "image")
    Cloudinary::Uploader.destroy(
      public_id,
      resource_type: resource_type,   # "image" sau "video"
      invalidate: true
    )
  rescue => e
    Rails.logger.warn("Cloudinary delete failed for #{public_id}: #{e.message}")
  end
end