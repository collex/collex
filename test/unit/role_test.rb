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

class RoleTest < ActiveSupport::TestCase
  fixtures :users, :roles, :roles_users

  def setup
    @admin_user = users "admin"
    @admin_role = roles "admin"
    @editor_user = users "editor"
    @editor_role = roles "editor"
    @basic_user = users "basic"
  end
  
  def test_admin_role_has_admin_user
    assert(role = Role.find(@admin_role.id), "Failed to find admin role.")
    assert(role.users.size == 1, "Admin Role should have one user.")
    assert(role.users.include?(@admin_user), "Admin Role should have admin user.")
  end
  def test_editor_role_has_editor_user
    assert(role = Role.find(@editor_role.id), "Failed to find editor role.")
    assert(role.users.size == 1, "Editor Role should have one user.")
    assert(role.users.include?(@editor_user), "Editor Role should have editor user.")
  end
end
