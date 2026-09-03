class GroupsController < ApplicationController
  layout "dashboard"

  def index
    @groups = Current.user.created_groups
  end

  def new
    @group = Group.new(
      join_requires_approval: true,
      public: true,
    )

    @groups = Current.user.created_groups
  end

  def create
    unless Current.user.can_create_group?
      redirect_to new_group_path,
                  alert: "Poți crea maximum 2 grupuri."
      return
    end

    @group = Current.user.created_groups.build(group_params)

    if @group.save
      redirect_to new_group_path,
                  notice: "Grupul a fost creat cu succes."
    else
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