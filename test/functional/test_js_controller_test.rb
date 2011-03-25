require 'test_helper'

class TestJsControllerTest < ActionController::TestCase
  test "should get general_dialog" do
    get :general_dialog
    assert_response :success
  end

end
