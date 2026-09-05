require "test_helper"

class GroupMembersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get group_members_index_url
    assert_response :success
  end
end
