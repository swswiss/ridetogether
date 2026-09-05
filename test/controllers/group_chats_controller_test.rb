require "test_helper"

class GroupChatsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get group_chats_show_url
    assert_response :success
  end
end
