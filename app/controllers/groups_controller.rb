class GroupsController < ApplicationController
  layout "dashboard"

  def index
    @groups_per_city = Group
      .where(city: Current.user.city)
      .where.not(
        id: Current.user.group_memberships
          .where(status: "active")
          .select(:group_id)
      )
  end

  def my_groups
    @my_own_groups= Current.user.created_groups
    @my_groups_member = Group.where(
      id: Current.user.group_memberships
        .where(role: "member", status: "active")
        .select(:group_id)
    )
    @my_groups_moderator = Group.where(
      id: Current.user.group_memberships
        .where(role: "moderator", status: "active")
        .select(:group_id)
    )
  end

  def new
    @group = Group.new(
      join_requires_approval: true,
      public: true,
    )

    @groups = Current.user.created_groups
  end

  def show
    @group = Group.find(params[:id])
    @membership = @group.group_memberships.find_by(user: Current.user)
  end

  def create
    unless Current.user.can_create_group?
      redirect_to new_group_path,
                  alert: "Poți crea maximum 2 grupuri."
      return
    end

    @group = Current.user.created_groups.build(group_params)

    begin
      Group.transaction do
        @group.save!
  
        @group.group_memberships.create!(
          user: Current.user,
          role: "admin",
          status: "active"
        )
      end
  
      redirect_to new_group_path,
                  notice: "Grupul a fost creat cu succes."
    rescue ActiveRecord::RecordInvalid
      @groups = Current.user.created_groups.reload
      flash.now[:alert] = "Grupul nu a putut fi creat."
      render :new, status: :unprocessable_entity
    end
  end

  private

  def group_params
    params.require(:group).permit(
      :name,
      :city,
      :description,
      :join_requires_approval,
      :public,
      ride_types: []
    )
  end
end