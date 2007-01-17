require File.dirname(__FILE__) + '/../test_helper'
require 'exhibits_controller'

# Re-raise errors caught by the controller.
class ExhibitsController; def rescue_action(e) raise e end; end

class ExhibitsControllerTest < Test::Unit::TestCase
  fixtures :exhibits

  def setup
    @controller = ExhibitsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:exhibits)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_exhibit
    old_count = Exhibit.count
    post :create, :exhibit => { }
    assert_equal old_count+1, Exhibit.count
    
    assert_redirected_to exhibit_path(assigns(:exhibit))
  end

  def test_should_show_exhibit
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_exhibit
    put :update, :id => 1, :exhibit => { }
    assert_redirected_to exhibit_path(assigns(:exhibit))
  end
  
  def test_should_destroy_exhibit
    old_count = Exhibit.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Exhibit.count
    
    assert_redirected_to exhibits_path
  end
end
