class RoutesController < ApplicationController
  layout "dashboard"

  before_action :set_route, only: [:destroy]

  def index
    @routes = Current.user.routes.order(created_at: :desc)
  end

  def new
    @route = Current.user.routes.build
  end

  def create
    @route = Current.user.routes.build(route_params)

    if @route.save
      redirect_to routes_path, notice: "Traseul „#{@route.name}” a fost salvat."
    else
      flash.now[:alert] = @route.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @route.destroy
    redirect_to routes_path, notice: "Traseul a fost șters."
  end

  private

  def set_route
    @route = Current.user.routes.find(params[:id])
  end

  def route_params
    permitted = params.require(:route).permit(:name, :distance_km, :coordinates)

    if permitted[:coordinates].is_a?(String) && permitted[:coordinates].present?
      permitted[:coordinates] = JSON.parse(permitted[:coordinates])
    end

    permitted
  rescue JSON::ParserError
    permitted.merge(coordinates: [])
  end
end
