class EventGalleriesController < ApplicationController
  include GroupContext
  layout "dashboard"

  before_action :set_event
  before_action :set_photo, only: :destroy
  before_action :require_photo_owner_or_organizer, only: :destroy
  before_action :require_organizer, only: :destroy_all

  def index
    @photos = @event.event_photos.includes(:user).order(created_at: :desc)
    @can_upload = @photos.size < EventPhoto::MAX_PER_EVENT
    @remaining = EventPhoto::MAX_PER_EVENT - @photos.size
  end

  def signature
    if @event.event_photos.count >= EventPhoto::MAX_PER_EVENT
      render json: { error: "Ai atins limita de #{EventPhoto::MAX_PER_EVENT} fișiere." },
             status: :unprocessable_entity
      return
    end

    render json: SignedUploadService.call(event: @event)
  end

  def create
    @photo = @event.event_photos.build(photo_params)
    @photo.user = Current.user

    if @photo.save
      #NotifyNewPhotoJob.perform_later(@photo.id)
      respond_to do |format|
        format.turbo_stream
        format.json { render json: { id: @photo.id }, status: :created }
        format.html { redirect_to group_event_gallery_path(@group, @event) }
      end
    else
      if @photo.cloudinary_public_id.present?
        CloudinaryCleanupJob.perform_later(
          @photo.cloudinary_public_id,
          @photo.resource_type || "image"
        )
      end
      
      respond_to do |format|
        format.json { render json: { errors: @photo.errors.full_messages }, status: :unprocessable_entity }
        format.html { redirect_to group_event_gallery_path(@group, @event), alert: @photo.errors.full_messages.to_sentence }
      end
    end
  end

  def destroy
    @photo.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to group_event_gallery_path(@group, @event) }
    end
  end

  def destroy_all
    @event.event_photos.find_each(&:destroy)   # fiecare declanșează cleanup Cloudinary
    redirect_to group_event_gallery_path(@group, @event),
                notice: "Toate fișierele au fost șterse."
  end

  private

  def set_event
    @event = @group.events.find(params[:event_id])
  end

  def set_photo
    @photo = @event.event_photos.find(params[:id])
  end

  def require_photo_owner_or_organizer
    return if @photo.user_id == Current.user.id
    return if @event.user_id == Current.user.id

    redirect_to group_event_gallery_path(@group, @event),
                alert: "Nu ai permisiunea să ștergi această poză."
  end

  def require_organizer
    return if @event.user_id == Current.user.id
    redirect_to group_event_gallery_path(@group, @event),
                alert: "Doar organizatorul poate șterge toate fișierele."
  end

  def photo_params
    params.require(:event_photo).permit(:cloudinary_public_id, :width, :height, :resource_type)
  end
end
