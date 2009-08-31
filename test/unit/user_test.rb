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

class UserTest < ActiveSupport::TestCase
  fixtures :users, :roles, :roles_users

  def setup
    @admin_user = users "admin"
    @admin_role = roles "admin"
    @editor_user = users "editor"
    @editor_role = roles "editor"
    @basic_user = users "basic"
  end
  
  def test_has_admin_role
    assert(user = User.find(@admin_user.id), "Couldn't find admin user.")
    assert(user.roles.size == 1, "User should have one role.")
    assert(user.roles.include?(@admin_role), "User should have admin role.")
    assert_equal(['admin'], user.role_names)
  end
  
  def test_has_editor_role
    assert(user = User.find(@editor_user.id), "Couldn't find editor user.")
    assert(user.roles.size == 1, "User should have one role.")
    assert(user.roles.include?(@editor_role), "User should have editor role.")
    assert_equal(['editor'], user.role_names)
  end
  
  def test_has_basic_role
    assert(user = User.find(@basic_user.id), "Couldn't find basic user.")
    assert(user.roles.empty?, "Basic User should have no roles.")
    assert_equal([], user.role_names)
  end
  
  def test_roles_available_as_boolean_attribute
    assert_nothing_raised(NoMethodError, "admin_role? should not raise an error.") { @admin_user.admin_role? }
    assert_nothing_raised(NoMethodError, "editor_role? should not raise an error.") { @editor_user.editor_role? }
    assert(@admin_user.admin_role?, "admin_role? should respond true")
    assert(@editor_user.editor_role?, "editor_role? should respond true")
    
    assert_nothing_raised(NoMethodError, "editor_role? should respond false.") { @admin_user.editor_role? }
    assert_nothing_raised(NoMethodError, "admin_role? should respond false.") { @editor_user.admin_role? }
    assert(!@admin_user.editor_role?, "editor_role? should respond true")
    assert(!@editor_user.admin_role?, "admin_role? should respond true")
    
    # Make sure method_missing still throws errors on non _role? attributes that don't exist
    assert_raise(NoMethodError, "admin? should throw an NoMethodError on @admin_user") { @admin_user.admin? }
    assert_raise(NoMethodError, "editor? should throw an NoMethodError on @admin_user") { @editor_user.editor? }
  end
  
  
end
