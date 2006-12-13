require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/default_controller'

# Re-raise errors caught by the controller.
class Admin::DefaultController; def rescue_action(e) raise e end; end

class Admin::DefaultControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::DefaultController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
