class EventParticipationsController < ApplicationController
  include GroupContext

  layout "dashboard"

  def create
    @event = @group.events.find(params[:event_id])

    @participation = EventParticipation.find_or_initialize_by(
      event: @event,
      user: Current.user
    )

    @participation.status = participation_params[:status]
    if participation_params[:status] == "not_going" && @participation.present?
      @participation.destroy
      load_participants
      respond_to do |format|
        format.turbo_stream
        format.html do
          redirect_to group_event_path(@group, @event)
        end
      end
    else
      if @participation.save
        load_participants

        respond_to do |format|
          format.turbo_stream
          format.html do
            redirect_to group_event_path(@group, @event)
          end
        end
      else
        redirect_to group_event_path(@group, @event),
                    alert: @participation.errors.full_messages.to_sentence
      end
    end
  end

  private

  def participation_params
    params.require(:event_participation).permit(:status)
  end

  def load_participants
    @going_participants = @event.event_participations
                                 .where(status: "going")
                                 .includes(:user)
                                 .order(created_at: :asc)

    @going_count = @going_participants.size

    @current_participation = @event.event_participations.find_by(
      user: Current.user
    )
  end
end