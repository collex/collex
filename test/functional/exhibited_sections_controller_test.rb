##########################################################################
# Copyright 2007 Applied Research in Patacriticism
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################

require File.dirname(__FILE__) + '/../test_helper'
require 'exhibited_sections_controller'

# Re-raise errors caught by the controller.
class ExhibitedSectionsController; def rescue_action(e) raise e end; end

class ExhibitedSectionsControllerTest < Test::Unit::TestCase
  fixtures :exhibits, :exhibited_pages, :exhibited_items, :exhibited_sections, :users
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
    post(:move_higher, :id => @es3.id, :page_id => @ep1.id, :exhibit_id => @exhibit.id)
    @es3.reload
    @es2.reload
    assert(@es3.position < @es2.position)
    assert_response(:redirect)
    assert_redirected_to(edit_page_path(:exhibit_id => @exhibit, :id => @ep1.id, :anchor => "exhibited_section_#{@es3.id}"))
    
    assert(@es3.position > @es1.position)
    post(:move_higher, :id => @es3.id, :page_id => @ep1.id, :exhibit_id => @exhibit.id)
    @es3.reload
    @es1.reload
    assert(@es3.position < @es1.position)
    assert_response(:redirect)
    assert_redirected_to(edit_page_path(:exhibit_id => @exhibit, :id => @ep1.id, :anchor => "exhibited_section_#{@es3.id}"))
  end
  def test_moves_section_lower_and_returns_to_proper_page
    assert(@es1.position < @es2.position)
    post(:move_lower, :id => @es1.id, :page_id => @ep1.id, :exhibit_id => @exhibit.id)
    @es1.reload
    @es2.reload
    assert(@es1.position > @es2.position)
    assert_response(:redirect)
    assert_redirected_to(edit_page_path(:exhibit_id => @exhibit, :id => @ep1.id, :anchor => "exhibited_section_#{@es1.id}"))
    
    assert(@es1.position < @es3.position)
    post(:move_lower, :id => @es1.id, :page_id => @ep1.id, :exhibit_id => @exhibit.id)
    @es1.reload
    @es3.reload
    assert(@es1.position > @es3.position)
    assert_response(:redirect)
    assert_redirected_to(edit_page_path(:exhibit_id => @exhibit, :id => @ep1.id, :anchor => "exhibited_section_#{@es1.id}"))
  end
  def test_moves_section_to_top_and_returns_to_proper_page
    assert(@es1.position < @es2.position && @es2.position < @es3.position)
    post(:move_to_top, :id => @es3.id, :page_id => @ep1.id, :exhibit_id => @exhibit.id)
    @es1.reload
    @es2.reload
    @es3.reload
    assert(@es2.position > @es1.position && @es1.position > @es3.position)
    assert_response(:redirect)
    assert_redirected_to(edit_page_path(:exhibit_id => @exhibit, :id => @ep1.id, :anchor => "exhibited_section_#{@es3.id}"))
  end
  def test_moves_section_to_bottom_and_returns_to_proper_page
    assert(@es1.position < @es2.position && @es2.position < @es3.position)
    post(:move_to_bottom, :id => @es1.id, :page_id => @ep1.id, :exhibit_id => @exhibit.id)
    @es1.reload
    @es2.reload
    @es3.reload
    assert(@es1.position > @es3.position && @es3.position > @es2.position)
    assert_response(:redirect)
    assert_redirected_to(edit_page_path(:exhibit_id => @exhibit, :id => @ep1.id, :anchor => "exhibited_section_#{@es1.id}"))
  end
end
