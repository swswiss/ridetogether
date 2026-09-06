class GroupMembersController < ApplicationController
  include GroupContext

  layout "dashboard"

  def index
    @memberships = @group.group_memberships
                         .where(status: "active")
                         .includes(:user)
                         .order(:created_at)
  end
end
