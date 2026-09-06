class GroupSettingsController < ApplicationController
  include GroupContext

  layout "dashboard"

  before_action :require_admin_or_moderator

  def show
  end

  def update
    if @group.update(group_params)
      redirect_to group_settings_path(@group),
                  notice: "Setările grupului au fost actualizate."
    else
      flash.now[:alert] = "Setările nu au putut fi salvate."
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    unless @membership&.admin?
      redirect_to group_path(@group),
                  alert: "Doar un administrator poate șterge grupul."
      return
    end

    @group.destroy!

    redirect_to groups_path,
                notice: "Grupul a fost șters."
  end

  private

  def group_params
    params.require(:group).permit(
      :name,
      :description,
      :join_requires_approval,
      :public,
      ride_types: []
    )
  end

  def require_admin_or_moderator
    return if @membership&.admin? || @membership&.moderator?

    redirect_to group_path(@group), alert: "Nu ai acces la această secțiune."
  end
end
