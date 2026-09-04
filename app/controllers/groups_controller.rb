class GroupsController < ApplicationController
  layout "dashboard"

  def index
    @my_own_groups= Current.user.created_groups
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