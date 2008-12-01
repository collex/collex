require File.dirname(__FILE__) + '/../test_helper'

class ExhibitObjectsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:exhibit_objects)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_exhibit_object
    assert_difference('ExhibitObject.count') do
      post :create, :exhibit_object => { }
    end

    assert_redirected_to exhibit_object_path(assigns(:exhibit_object))
  end

  def test_should_show_exhibit_object
    get :show, :id => exhibit_objects(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => exhibit_objects(:one).id
    assert_response :success
  end

  def test_should_update_exhibit_object
    put :update, :id => exhibit_objects(:one).id, :exhibit_object => { }
    assert_redirected_to exhibit_object_path(assigns(:exhibit_object))
  end

  def test_should_destroy_exhibit_object
    assert_difference('ExhibitObject.count', -1) do
      delete :destroy, :id => exhibit_objects(:one).id
    end

    assert_redirected_to exhibit_objects_path
  end
end
