require File.dirname(__FILE__) + '/../test_helper'

class ExhibitSectionsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:exhibit_sections)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_exhibit_section
    assert_difference('ExhibitSection.count') do
      post :create, :exhibit_section => { }
    end

    assert_redirected_to exhibit_section_path(assigns(:exhibit_section))
  end

  def test_should_show_exhibit_section
    get :show, :id => exhibit_sections(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => exhibit_sections(:one).id
    assert_response :success
  end

  def test_should_update_exhibit_section
    put :update, :id => exhibit_sections(:one).id, :exhibit_section => { }
    assert_redirected_to exhibit_section_path(assigns(:exhibit_section))
  end

  def test_should_destroy_exhibit_section
    assert_difference('ExhibitSection.count', -1) do
      delete :destroy, :id => exhibit_sections(:one).id
    end

    assert_redirected_to exhibit_sections_path
  end
end
