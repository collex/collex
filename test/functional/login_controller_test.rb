require File.dirname(__FILE__) + '/../test_helper'
require 'login_controller'

# Re-raise errors caught by the controller.
class LoginController; def rescue_action(e) raise e end; end

class LoginControllerTest < Test::Unit::TestCase
#  fixtures :users
  
  def setup
    @controller = LoginController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_authenticated_action_without_user
     get :controller => "collection"
     
     assert_redirected_to :action => "login", :controller => "login"
  end

  def test_login_with_valid_user 
    post :login, {:username => 'username', :password => 'password'} 
    
    assert_redirected_to :controller => "sidebar", :action => "cloud", :type => "tag"
    assert_equal('username', session[:user][:username])  # Fix this
  end
end
