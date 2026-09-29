# app/controllers/mission_control_controller.rb

class MissionControlController < ApplicationController
  before_action :require_admin

  private

  def require_admin
    head :forbidden unless Current.session&.user&.admin?
  end
end