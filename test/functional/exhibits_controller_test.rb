##########################################################################
# Copyright 2007 Applied Research in Patacriticism and the University of Virginia
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
require 'exhibits_controller'

# Re-raise errors caught by the controller.
class ExhibitsController; def rescue_action(e) raise e end; end

#TODO need test coverage of edit/update and Paging


# NOTE this test relies on FormTestHelper plugin:
# http://form-test-helper.googlecode.com/svn/form_test_helper
class ExhibitsControllerTest < Test::Unit::TestCase
  fixtures :exhibits, :exhibited_items, :exhibited_sections, :users, :roles, :roles_users
  fixtures :licenses, :exhibit_section_types, :exhibit_types

  def setup
    @controller = ExhibitsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @exhibit = exhibits(:dang)
    @owner = users(:exhibit_owner)
    @viewer = users(:exhibit_viewer)
    @request.session[:user] = {:username => @owner.username}
    @admin = users(:admin)
    @editor = users(:editor)
  end

  def test_sanity
    assert(true)
  end
#   
#   def test_gets_index_as_sanity_check
#     get(:index)
#     assert_response(:success)
#     assert(assigns(:exhibits), "Should have assigned :exhibits")
#   end

#   def test_can_necrd_when_logged_in
#     # updates are done via ajax
#     assertions = proc do |response|
#       assert_response(response)
#       assert(exhibit = assigns(:exhibit), "Should have assigned :exhibit")
#       assert(exhibit.errors.empty?, "@exhibit should not have errors: #{exhibit.errors.inspect}")
#     end
#     exhibit_count = Exhibit.count
#     get(:new)
#     assertions.call(:success)
#     submit_form('new_exhibit') do |f|
#       f.exhibit.title = "New Exhibit"
#       f.exhibit.exhibit_type_id = 1
#       f.exhibit.license_id = 1
#       f.exhibit.annotation = "Exhibit notes."
#     end
#     assert_equal(exhibit_count += 1, Exhibit.count )
#     assertions.call(:redirect)
#     assert_redirected_to(edit_exhibit_path(assigns(:exhibit)))
#     assert(flash[:notice])
#     
#     get(:edit, :id => @exhibit.id)
#     assertions.call(:success)
# 
#     delete(:destroy, :id => @exhibit.id)   
#     assert_equal(exhibit_count -= 1, Exhibit.count )
#     assert_response(:redirect)
#     assert_redirected_to(exhibits_path)
#   end
  
    
end
