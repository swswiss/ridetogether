# ═══════════════════════════════════════════════════════
# PASUL 5 — Service: semnătura pentru direct upload
# app/services/signed_upload_service.rb
# ═══════════════════════════════════════════════════════
#
# Generează parametrii semnați de care browser-ul are nevoie ca să încarce
# DIRECT în Cloudinary, în siguranță. Semnătura se face cu api_secret
# (care NU ajunge niciodată în browser) — Cloudinary verifică semnătura
# și acceptă upload-ul doar dacă e validă.
#
# De ce service: izolăm logica Cloudinary aici; controllerul rămâne subțire.

class SignedUploadService
  # folder-ul unde grupăm pozele pe Cloudinary (organizare)
  def self.call(event:)
    new(event: event).call
  end

  def initialize(event:)
    @event = event
  end

  def call
    timestamp = Time.now.to_i

    # parametrii pe care îi semnăm (trebuie să corespundă cu ce trimite browser-ul)
    params_to_sign = {
      timestamp: timestamp,
      folder: folder
    }

    signature = Cloudinary::Utils.api_sign_request(
      params_to_sign,
      Cloudinary.config.api_secret
    )

    # ce returnăm browser-ului (fără secret!)
    {
      signature:  signature,
      timestamp:  timestamp,
      api_key:    Cloudinary.config.api_key,
      cloud_name: Cloudinary.config.cloud_name,
      folder:     folder
    }
  end

  private

  def folder
    "ridetogether/events/#{@event.id}"
  end
end
