class GroupMembershipRequestsController < ApplicationController
  include GroupContext

  layout "dashboard"

  before_action :require_admin_or_moderator

  def index
    memberships = @group.group_memberships
                        .where(status: %w[pending rejected])
                        .includes(:user)

    @pending_requests = memberships.select(&:pending?)
    @rejected_requests = memberships.select(&:rejected?)
  end

  def approve
    request = find_request
    request.update!(status: "active")

    redirect_to group_membership_requests_path(@group),
                notice: "Cererea a fost acceptată."
  end

  def reject
    request = find_pending_request
    request.update!(status: "rejected")

    redirect_to group_membership_requests_path(@group),
                notice: "Cererea a fost respinsă."
  end

  private

  def find_request
    @group.group_memberships.find_by!(id: params[:id])
  end
  
  def find_pending_request
    @group.group_memberships.find_by!(
      id: params[:id],
      status: "pending"
    )
  end

  def require_admin_or_moderator
    return if @membership&.admin? || @membership&.moderator?

    redirect_to group_path(@group), alert: "Nu ai acces la această secțiune."
  end
end