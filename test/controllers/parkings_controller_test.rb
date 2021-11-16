require "test_helper"

class ParkingsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get parkings_show_url
    assert_response :success
  end
end
