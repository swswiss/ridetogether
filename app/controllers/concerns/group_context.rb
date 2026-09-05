module GroupContext
  extend ActiveSupport::Concern

  included do
    before_action :set_group
    before_action :set_membership
  end

  private

  def set_group
    @group = Group.find(params[:group_id])
  end

  def set_membership
    @membership = @group.group_memberships.find_by(user: Current.user)
  end
end