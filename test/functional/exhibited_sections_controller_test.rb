require File.dirname(__FILE__) + '/../test_helper'
require 'exhibited_sections_controller'

# Re-raise errors caught by the controller.
class ExhibitedSectionsController; def rescue_action(e) raise e end; end

class ExhibitedSectionsControllerTest < Test::Unit::TestCase
  fixtures :exhibits, :exhibited_pages, :exhibited_resources, :exhibited_sections, :users
  fixtures :licenses, :exhibit_page_types, :exhibit_section_types, :exhibit_types
  def setup
    @controller = ExhibitedSectionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @owner = users(:exhibit_owner)
    @viewer = users(:exhibit_viewer)
    @request.session[:user] = {:username => @owner.username}

    @exhibit = exhibits(:illustrated_essay)
    @ep1 = exhibited_pages(:illustrated_essay_1)
    @es1 = exhibited_sections(:illustrated_essay_1)
    @es2 = exhibited_sections(:illustrated_essay_2)
    @es3 = exhibited_sections(:illustrated_essay_3)
  end

  def test_redirects_to_login_if_not_logged_in
    @request.session[:user] = nil
    post(:move_higher, :id => @es2.id, :exhibit_id => @exhibit.id)
    assert_response(:redirect)
    assert_redirected_to(:action => "login", :controller => "login")
  end

  def test_redirects_to_exhibits_index_if_not_owner
    @request.session[:user] = {:username => @viewer.username}
    post(:move_higher, :id => @es2.id, :exhibit_id => @exhibit.id)
    assert_response(:redirect)
    assert_redirected_to(exhibits_path)
  end
  def test_moves_section_higher_and_returns_to_proper_page
    assert(@es3.position > @es2.position)
    post(:move_higher, :id => @es3.id, :exhibited_page_id => @ep1.id, :exhibit_id => @exhibit.id, :page => 1)
    @es3.reload
    @es2.reload
    assert(@es3.position < @es2.position)
    assert_response(:redirect)
    assert_redirected_to(edit_exhibit_path(:id => @exhibit, :page => @request.params[:page], :anchor => "exhibited_section_#{@es3.id}"))
    
    assert(@es3.position > @es1.position)
    post(:move_higher, :id => @es3.id, :exhibited_page_id => @ep1.id, :exhibit_id => @exhibit.id, :page => 1)
    @es3.reload
    @es1.reload
    assert(@es3.position < @es1.position)
    assert_response(:redirect)
    assert_redirected_to(edit_exhibit_path(:id => @exhibit, :page => @request.params[:page], :anchor => "exhibited_section_#{@es3.id}"))
  end
  def test_moves_section_lower_and_returns_to_proper_page
    assert(@es1.position < @es2.position)
    post(:move_lower, :id => @es1.id, :exhibited_page_id => @ep1.id, :exhibit_id => @exhibit.id, :page => 1)
    @es1.reload
    @es2.reload
    assert(@es1.position > @es2.position)
    assert_response(:redirect)
    assert_redirected_to(edit_exhibit_path(:id => @exhibit, :page => @request.params[:page], :anchor => "exhibited_section_#{@es1.id}"))
    
    assert(@es1.position < @es3.position)
    post(:move_lower, :id => @es1.id, :exhibited_page_id => @ep1.id, :exhibit_id => @exhibit.id, :page => 1)
    @es1.reload
    @es3.reload
    assert(@es1.position > @es3.position)
    assert_response(:redirect)
    assert_redirected_to(edit_exhibit_path(:id => @exhibit, :page => @request.params[:page], :anchor => "exhibited_section_#{@es1.id}"))
  end
  def test_moves_section_to_top_and_returns_to_proper_page
    assert(@es1.position < @es2.position && @es2.position < @es3.position)
    post(:move_to_top, :id => @es3.id, :exhibited_page_id => @ep1.id, :exhibit_id => @exhibit.id, :page => 1)
    @es1.reload
    @es2.reload
    @es3.reload
    assert(@es2.position > @es1.position && @es1.position > @es3.position)
    assert_response(:redirect)
    assert_redirected_to(edit_exhibit_path(:id => @exhibit, :page => @request.params[:page], :anchor => "exhibited_section_#{@es3.id}"))
  end
  def test_moves_section_to_bottom_and_returns_to_proper_page
    assert(@es1.position < @es2.position && @es2.position < @es3.position)
    post(:move_to_bottom, :id => @es1.id, :exhibited_page_id => @ep1.id, :exhibit_id => @exhibit.id, :page => 1)
    @es1.reload
    @es2.reload
    @es3.reload
    assert(@es1.position > @es3.position && @es3.position > @es2.position)
    assert_response(:redirect)
    assert_redirected_to(edit_exhibit_path(:id => @exhibit, :page => @request.params[:page], :anchor => "exhibited_section_#{@es1.id}"))
  end
end
