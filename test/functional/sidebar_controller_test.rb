require File.dirname(__FILE__) + '/../test_helper'
require 'sidebar_controller'

# Re-raise errors caught by the controller.
class SidebarController; def rescue_action(e) raise e end; end

class SidebarControllerTest < Test::Unit::TestCase
  def setup
    @controller = SidebarController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_bad_objid_detail
    get :detail, {"objid" => CollexEngine::BAD_OBJID}
    assert_response :redirect
    assert_redirected_to :controller => "sidebar", :action => "cloud" 
  end
  
end
