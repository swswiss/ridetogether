require "test_helper"

class GroupEventsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get group_events_index_url
    assert_response :success
  end
end
