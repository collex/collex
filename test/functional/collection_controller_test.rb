require File.dirname(__FILE__) + '/../test_helper'
require 'collection_controller'

# Re-raise errors caught by the controller.
class CollectionController; def rescue_action(e) raise e end; end

class CollectionControllerTest < Test::Unit::TestCase
  fixtures :users
  
  def setup
    @controller = CollectionController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @request.session[:user] = {:username => "dave"}
  end

  def test_collect
     # tests that collect page is gotten to successfully, meaning the session has a user
     get :collect, :url => 'http://www.foo.com'
     assert_response :success
  end
  
  def test_add
     uri = "http://www.rossettiarchive.org/docs/test.test"
     
     post :add, {"tags-#{uri}" => "some tags", "notes-#{uri}" => "test annotation"}
     
     assert_response :success
  end
  
end
