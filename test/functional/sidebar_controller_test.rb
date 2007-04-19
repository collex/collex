require File.dirname(__FILE__) + '/../test_helper'
require 'sidebar_controller'

# Re-raise errors caught by the controller.
class SidebarController; def rescue_action(e) raise e end; end

class SidebarControllerTest < Test::Unit::TestCase
  fixtures :interpretations
  
  def setup
    @controller = SidebarController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @request.session[:user] = {:username => "dave"}
  end

  def test_bad_objid_detail
    get :detail, {"objid" => CollexEngine::BAD_OBJID}
    assert_response :redirect
    assert_redirected_to :controller => "sidebar", :action => "cloud" 
  end
  
  def test_update
    get :update, "tags"=>"consist of three parts",
                 "action"=>"update", 
                 "controller"=>"sidebar", 
                 "objid"=>"http://www.rossettiarchive.org/docs/1-1864.s105.raw",
                 "annotation"=>"annotate this item"
                 
     get :update, "tags"=>"consist of three parts",
                  "action"=>"update", 
                  "controller"=>"sidebar", 
                  "objid"=>"http://www.rossettiarchive.org/docs/1-1864.s105.raw",
                  "annotation"=>"annotate this item"
                 
    assert_redirected_to :action => 'detail', :objid => "http://www.rossettiarchive.org/docs/1-1864.s105.raw"
    
    user = User.find_by_username(session[:user][:username])
  end  
end
