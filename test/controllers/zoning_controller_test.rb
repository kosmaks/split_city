require 'test_helper'

class ZoningControllerTest < ActionController::TestCase
  test "should get debug" do
    get :debug
    assert_response :success
  end

end
