module GroupContext
  extend ActiveSupport::Concern

  included do
    before_action :set_group
    before_action :set_membership
    before_action :require_group_member
  end

  private

  def set_group
    @group = Group.find(params[:group_id])
  end

  def set_membership
    @membership = @group.group_memberships.find_by(user: Current.user)
  end

  def require_group_member
    unless @membership&.status == "active"
      redirect_to groups_path,
                  alert: "Nu faci parte din acest grup."
    end
  end
end