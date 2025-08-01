require "test_helper"

class GuideControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get guide_url
    assert_response :success
  end
end
