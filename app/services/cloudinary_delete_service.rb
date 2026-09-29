# ═══════════════════════════════════════════════════════
# PASUL 6 — Service: ștergerea de pe Cloudinary
# app/services/cloudinary_delete_service.rb
# ═══════════════════════════════════════════════════════
#
# Șterge o poză de pe Cloudinary după public_id.
# Folosit de job-ul de cleanup (nu direct din controller — vezi jobs).

class CloudinaryDeleteService
  def self.call(public_id)
    new(public_id).call
  end

  def initialize(public_id)
    @public_id = public_id
  end

  def call
    return if @public_id.blank?

    Cloudinary::Uploader.destroy(@public_id, invalidate: true)
    # invalidate: true → curăță și cache-ul CDN pentru poza ștearsă
  rescue => e
    # nu vrem să crape job-ul dacă poza deja nu mai există etc.
    Rails.logger.warn("Cloudinary delete failed for #{@public_id}: #{e.message}")
  end
end
