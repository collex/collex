require File.dirname(__FILE__) + '/../test_helper'

class ExhibitIllustrationsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:exhibit_illustrations)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_exhibit_illustration
    assert_difference('ExhibitIllustration.count') do
      post :create, :exhibit_illustration => { }
    end

    assert_redirected_to exhibit_illustration_path(assigns(:exhibit_illustration))
  end

  def test_should_show_exhibit_illustration
    get :show, :id => exhibit_illustrations(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => exhibit_illustrations(:one).id
    assert_response :success
  end

  def test_should_update_exhibit_illustration
    put :update, :id => exhibit_illustrations(:one).id, :exhibit_illustration => { }
    assert_redirected_to exhibit_illustration_path(assigns(:exhibit_illustration))
  end

  def test_should_destroy_exhibit_illustration
    assert_difference('ExhibitIllustration.count', -1) do
      delete :destroy, :id => exhibit_illustrations(:one).id
    end

    assert_redirected_to exhibit_illustrations_path
  end
end
