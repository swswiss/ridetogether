require "test_helper"

class GroupSettingsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get group_settings_show_url
    assert_response :success
  end
end
