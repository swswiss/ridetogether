class MembershipsController < ApplicationController
  def create
    @group = Group.find(params[:group_id])

    existing_membership = @group.group_memberships.find_by(user: Current.user)

    if existing_membership
      redirect_to group_path(@group), alert: "Ai deja o cerere sau ești deja membru."
      return
    end

    status = @group.join_requires_approval? ? "pending" : "active"

    @membership = @group.group_memberships.create!(
      user: Current.user,
      role: "member",
      status: status
    )

    if status == "pending"
      redirect_to group_path(@group), notice: "Cererea ta a fost trimisă."
    else
      redirect_to group_path(@group), notice: "Te-ai alăturat grupului."
    end
  end

  def destroy
    @group = Group.find(params[:group_id])
    @membership = @group.group_memberships.find_by(user: Current.user)
  
    if @membership&.pending?
      @membership.destroy
      redirect_to group_path(@group), notice: "Cererea a fost anulată."
    else
      redirect_to group_path(@group)
    end
  end
end