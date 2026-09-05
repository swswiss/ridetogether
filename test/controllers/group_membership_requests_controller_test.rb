require "test_helper"

class GroupMembershipRequestsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get group_membership_requests_index_url
    assert_response :success
  end
end
