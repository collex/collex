require File.dirname(__FILE__) + '/../test_helper'

class ExhibitPagesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:exhibit_pages)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_exhibit_page
    assert_difference('ExhibitPage.count') do
      post :create, :exhibit_page => { }
    end

    assert_redirected_to exhibit_page_path(assigns(:exhibit_page))
  end

  def test_should_show_exhibit_page
    get :show, :id => exhibit_pages(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => exhibit_pages(:one).id
    assert_response :success
  end

  def test_should_update_exhibit_page
    put :update, :id => exhibit_pages(:one).id, :exhibit_page => { }
    assert_redirected_to exhibit_page_path(assigns(:exhibit_page))
  end

  def test_should_destroy_exhibit_page
    assert_difference('ExhibitPage.count', -1) do
      delete :destroy, :id => exhibit_pages(:one).id
    end

    assert_redirected_to exhibit_pages_path
  end
end
