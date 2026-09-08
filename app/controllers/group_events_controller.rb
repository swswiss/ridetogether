class GroupEventsController < ApplicationController
  include GroupContext

  layout "dashboard"
  
  def index
    @upcoming_events = @group.events
                             .where("date >= ?", Date.current)
                             .order(date: :asc, time: :asc)
  
    @past_events = @group.events
                          .where("date < ?", Date.current)
                          .order(date: :desc, time: :desc)
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

  private

  def event_params
    params.require(:event).permit(
      :title,
      :ride_type,
      :date,
      :time,
      :start_location,
      :distance_km,
      :average_speed_kmh,
      :regime,
      :description
    )
  end
end
