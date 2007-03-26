require File.dirname(__FILE__) + '/../test_helper'
require 'exhibits_controller'

# Re-raise errors caught by the controller.
class ExhibitsController; def rescue_action(e) raise e end; end

class ExhibitsControllerTest < Test::Unit::TestCase
  fixtures :exhibits, :exhibited_resources, :exhibited_sections, :users
  fixtures :licenses, :exhibit_section_types, :exhibit_types

  def setup
    @controller = ExhibitsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @exhibit = exhibits(:dang)
    @owner = users(:exhibit_owner)
    @request.session[:user] = {:username => @owner.username}
  end

  def test_sanity
    assert(true)
  end
  
  def test_gets_index_as_sanity_check
    get(:index)
    assert_response(:success)
    assert(assigns(:exhibits), "Should have assigned :exhibits")
  end

  def test_new_exhibit_redirects_to_login_when_not_logged_in
    @request.session[:user] = nil
    get(:new)
    assert_redirected_to(:action => "login", :controller => "login")
  end
  
  def test_edit_bad_exhibit_id_redirects_to_login_when_not_logged_in
    @request.session[:user] = nil
    get(:edit, :id => -1)
    assert_redirected_to(:action => "login", :controller => "login")
  end
  
  def test_edit_bad_exhibit_id_redirects_to_index_with_warning_when_logged_in
    get(:edit, :id => -1)
    assert_redirected_to(exhibits_path)
    assert_not_nil(flash[:warning])
  end

#   def test_should_get_index
#     get :index
#     assert_response :success
#     assert assigns(:exhibits)
#   end
# 
#   def test_should_get_new
#     get :new
#     assert_response :success
#   end
#   
#   def test_should_create_exhibit
#     old_count = Exhibit.count
#     post :create, :exhibit => { }
#     assert_equal old_count+1, Exhibit.count
#     
#     assert_redirected_to exhibit_path(assigns(:exhibit))
#   end
# 
#   def test_should_show_exhibit
#     get :show, :id => 1
#     assert_response :success
#   end
# 
#   def test_should_get_edit
#     get :edit, :id => 1
#     assert_response :success
#   end
#   
#   def test_should_update_exhibit
#     put :update, :id => 1, :exhibit => { }
#     assert_redirected_to exhibit_path(assigns(:exhibit))
#   end
#   
#   def test_should_destroy_exhibit
#     old_count = Exhibit.count
#     delete :destroy, :id => 1
#     assert_equal old_count-1, Exhibit.count
#     
#     assert_redirected_to exhibits_path
#   end
end
