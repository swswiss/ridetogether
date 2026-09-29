class EventGalleriesController < ApplicationController
  include GroupContext
  layout "dashboard"

  before_action :set_event
  before_action :set_photo, only: :destroy
  before_action :require_photo_owner_or_organizer, only: :destroy

  def index
    @photos = @event.event_photos
                    .includes(:user)
                    .order(created_at: :desc)
  end

  def signature
    render json: SignedUploadService.call(event: @event)
  end

  def create
    @photo = @event.event_photos.build(photo_params)
    @photo.user = Current.user

    if @photo.save
      #NotifyNewPhotoJob.perform_later(@photo.id)

      respond_to do |format|
        format.turbo_stream   # adaugă poza în galerie instant
        format.json { render json: { id: @photo.id }, status: :created }
        format.html { redirect_to group_event_gallery_path(@group, @event) }
      end
    else
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

  def photo_params
    params.require(:event_photo).permit(:cloudinary_public_id, :width, :height)
  end
end
