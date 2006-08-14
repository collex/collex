require File.dirname(__FILE__) + '/../test_helper'
require 'collection_controller'

# Re-raise errors caught by the controller.
class CollectionController; def rescue_action(e) raise e end; end

class CollectionControllerTest < Test::Unit::TestCase
#  fixtures :items, :user_objects
  
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
     
     puts COLLEX_MANAGER.cache.to_s
     assert_redirected_to :action => "list"
     
#     item = Item.find_by_url(url)
     
#     assert_equal url, item.url
     
#     assert_equal 1, item.user_objects.length # dave's object
#     assert_equal "dave", item.user_objects[0].user.username
     
#     assert_equal 2, item.object_tags.length  # "blessed" and "damozel"
#     assert_equal "blessed", item.object_tags[0].tag
#     assert_equal "damozel", item.object_tags[1].tag
  end
  
end
