require File.dirname(__FILE__) + '/../test_helper'

class ExhibitElementsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:exhibit_elements)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_exhibit_element
    assert_difference('ExhibitElement.count') do
      post :create, :exhibit_element => { }
    end

    assert_redirected_to exhibit_element_path(assigns(:exhibit_element))
  end

  def test_should_show_exhibit_element
    get :show, :id => exhibit_elements(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => exhibit_elements(:one).id
    assert_response :success
  end

  def test_should_update_exhibit_element
    put :update, :id => exhibit_elements(:one).id, :exhibit_element => { }
    assert_redirected_to exhibit_element_path(assigns(:exhibit_element))
  end

  def test_should_destroy_exhibit_element
    assert_difference('ExhibitElement.count', -1) do
      delete :destroy, :id => exhibit_elements(:one).id
    end

    assert_redirected_to exhibit_elements_path
  end
end
