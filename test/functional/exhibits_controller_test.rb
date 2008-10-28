require File.dirname(__FILE__) + '/../test_helper'

class ExhibitsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:exhibits)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_exhibit
    assert_difference('Exhibit.count') do
      post :create, :exhibit => { }
    end

    assert_redirected_to exhibit_path(assigns(:exhibit))
  end

  def test_should_show_exhibit
    get :show, :id => exhibits(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => exhibits(:one).id
    assert_response :success
  end

  def test_should_update_exhibit
    put :update, :id => exhibits(:one).id, :exhibit => { }
    assert_redirected_to exhibit_path(assigns(:exhibit))
  end

  def test_should_destroy_exhibit
    assert_difference('Exhibit.count', -1) do
      delete :destroy, :id => exhibits(:one).id
    end

    assert_redirected_to exhibits_path
  end
end
