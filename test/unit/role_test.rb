require File.dirname(__FILE__) + '/../test_helper'

class RoleTest < Test::Unit::TestCase
  fixtures :users, :roles, :roles_users

  def setup
    @admin_user = users "admin"
    @admin_role = roles "admin"
    @editor_user = users "editor"
    @editor_role = roles "editor"
    @basic_user = users "basic"
  end
  
  # Replace this with your real tests.
  def test_truth
    assert true
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
