class GroupCalendarsController < ApplicationController
  include GroupContext

  layout "dashboard"

  def show
    start_date = params.fetch(:start_date, Date.current).to_date
    month_start = start_date.beginning_of_month
    month_end = start_date.end_of_month
  
    range = (month_start - 7)..(month_end + 7)
  
    @events = Rails.cache.fetch(
      ["group", @group.id, "calendar_events", month_start],
      expires_in: 30.minutes
    ) do
      @group.events
             .includes(:user)
             .where(date: range)
             .order(:date, :time)
             .to_a
    end
  
    @month_events = Rails.cache.fetch(
      ["group", @group.id, "month_events", month_start],
      expires_in: 30.minutes
    ) do
      @group.events
             .where(date: month_start..month_end)
             .order(:date, :time)
             .to_a
    end
  end

end
