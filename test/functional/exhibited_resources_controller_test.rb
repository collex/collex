require File.dirname(__FILE__) + '/../test_helper'
require 'exhibited_resources_controller'
require 'simply_helpful'

# Re-raise errors caught by the controller.
class ExhibitedResourcesController; def rescue_action(e) raise e end; end

class ExhibitedResourcesControllerTest < Test::Unit::TestCase
  fixtures :exhibits, :exhibited_resources, :exhibited_sections, :users
  fixtures :licenses, :exhibit_section_types, :exhibit_types
  def setup
    @controller = ExhibitedResourcesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @owner = users(:exhibit_owner)
    @viewer = users(:exhibit_viewer)
    @request.session[:user] = {:username => @owner.username}

    @exhibit = exhibits(:dang)
    @es = exhibited_sections(:dang_3)
    @er1 = exhibited_resources(:dang_3_1)
    @er2 = exhibited_resources(:dang_3_2)
    @er3 = exhibited_resources(:dang_3_3)
  end

  def test_redirects_to_login_if_not_logged_in
    @request.session[:user] = nil
    post(:move_higher, :id => @er2.id, :exhibit_id => @exhibit.id, :exhibited_section => @es.id)
    assert_response(:redirect)
    assert_redirected_to(:action => "login", :controller => "login")
  end

  def test_redirects_to_exhibits_index_if_not_owner
    @request.session[:user] = {:username => @viewer.username}
    post(:move_higher, :id => @er2.id, :exhibit_id => @exhibit.id, :exhibited_section => @es.id)
    assert_response(:redirect)
    assert_redirected_to(exhibits_path)
  end
  def test_moves_resource_higher_and_returns_to_proper_page
    assert(@er2.position > @er1.position)
    post(:move_higher, :id => @er2.id, :exhibit_id => @exhibit.id, :exhibited_section => @es.id, :page => 1)
    @er2.reload
    @er1.reload
    assert(@er2.position < @er1.position)
    assert_response(:redirect)
    assert_redirected_to(edit_exhibit_path(:id => @exhibit, :page => @request.params[:page], :anchor => "exhibited_resource_#{@er2.id}"))
  end
end
