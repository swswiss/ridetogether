class GroupMembersController < ApplicationController
  include GroupContext

  layout "dashboard"

  before_action :require_admin, except: :index

  def index
    @memberships = @group.group_memberships
                         .where(status: "active")
                         .includes(:user)
                         .order(:created_at)
  end

  def promote
    membership = @group.group_memberships.find(params[:id])
    new_role = params[:role] == "member" ? "member" : "moderator"
    membership.update!(role: new_role)

    redirect_to group_members_path(@group),
                notice: "#{membership.user.name} este acum #{new_role == 'moderator' ? 'moderator' : 'member'}."
  end

  def destroy
    membership = @group.group_memberships.find(params[:id])

    # Nu permite administratorului să se șteargă singur
    if membership.user == Current.user
      redirect_to group_members_path(@group),
                  alert: "Nu te poți elimina singur din grup."
      return
    end

    membership.destroy!

    redirect_to group_members_path(@group),
                notice: "#{membership.user.name} a fost scos din grup."
  end

  private

  def require_admin
    return if @membership&.admin?

    redirect_to group_path(@group),
                alert: "Doar administratorii pot modifica membrii."
  end
end
