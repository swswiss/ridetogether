class GroupEventsController < ApplicationController
  include GroupContext

  layout "dashboard"

  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_action :require_event_owner, only: [:edit, :update, :destroy]
  
  def index
    @upcoming_events = @group.events
                             .includes(:user)
                             .where("date >= ?", Date.current)
                             .order(date: :asc, time: :asc)
  
    @past_events = @group.events
                          .includes(:user)
                          .where("date < ?", Date.current)
                          .order(date: :desc, time: :desc)
                          .limit(5)
  end

  def show
    @current_participation = @event.event_participations.find_by(
      user: Current.user
    )
    @going_participants = @event.event_participations
                                 .where(status: "going")
                                 .includes(:user)
                                 .order(created_at: :asc)
  
    @going_count = @going_participants.size
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to group_event_path(@group, @event),
                  notice: "Tura a fost actualizată cu succes."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def archive
    @pagy, @past_events = pagy(
      :offset,
      @group.events
           .includes(:user)
           .where("date < ?", Date.current)
           .order(date: :desc, time: :desc),
      limit: 10
    )
  end

  def create
    @event = @group.events.build(event_params)
    @event.user = Current.user

    if @event.save
      redirect_to group_path(@group),
                  notice: "Tura a fost publicată cu succes."
    else
      redirect_to group_path(@group),
                  alert: @event.errors.full_messages.to_sentence
    end
  end

  def destroy
    @event.destroy
  
    redirect_to group_path(@group),
                notice: "Tura a fost ștearsă cu succes."
  end

  private

  def set_event
    @event = @group.events.find(params[:id])
  end

  def require_event_owner
    unless @event.user_id == Current.user.id
      redirect_to group_event_path(@group, @event),
                  alert: "Nu ai permisiunea să editezi această tură."
    end
  end

  def event_params
    params.require(:event).permit(
      :title,
      :ride_type,
      :date,
      :time,
      :start_location,
      :distance_km,
      :average_speed_kmh,
      :estimated_duration_minutes,
      :regime,
      :strava_link,
      :description
    )
  end
end
