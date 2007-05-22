require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
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
    assert_nothing_raised(NoMethodError, "admin? should respond true.") { @admin_user.admin? }
    assert_nothing_raised(NoMethodError, "editor? should respond true.") { @editor_user.editor? }
    
    assert_raise(NoMethodError, "editor? should throw an NoMethodError on @admin_user") { @admin_user.editor? }
    assert_raise(NoMethodError, "admin? should throw an NoMethodError on @admin_user") { @editor_user.admin? }
  end
  
  
end
