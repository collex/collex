require File.dirname(__FILE__) + '/../test_helper'
require 'admin_message_controller'

# Re-raise errors caught by the controller.
class AdminMessageController
  # Re-raise errors caught by the controller.
  def rescue_action(e) raise e end;

  attr_accessor :consider_local

  def local_request?
    @consider_local
  end
end
  

class AdminMessageControllerTest < Test::Unit::TestCase
  
  fixtures :sites

  def setup
    @controller = AdminMessageController.new
    @controller.consider_local = true
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_add_site
    now = Time.now
    post :add_site, :code => 'test', :description => "Description: #{now}"
    assert_response :success
    
    site = Site.find_by_code('test')
    assert_equal "Description: #{now}", site.description
  end

  def test_site_exists
    post :add_site, :code => 'rossetti', :description => "Thrown away description"
    assert_response :success

    site = Site.find_by_code('rossetti')
    assert_equal "The Rossetti Archive", site.description
  end

  def test_local_only_access
    @controller.consider_local = false
    get :add_site
    assert_response 401
  end
end
