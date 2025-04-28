require "test_helper"

class RoundControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get round_index_url
    assert_response :success
  end
end
