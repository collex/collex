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

class ExhibitTest < Test::Unit::TestCase
  fixtures :exhibits, :exhibited_pages, :exhibited_items, :exhibited_sections, :users, :roles, :roles_users
  fixtures :licenses, :exhibit_section_types, :exhibit_page_types, :exhibit_types
  
  # Note: only using fixtures for more static data.
  def setup
    @st = exhibit_section_types(:citation)
    @et = exhibit_types(:annotated_bibliography)
    @exhibit = exhibits(:dang)
    @owner = users(:exhibit_owner)
    @admin = users(:admin)
    @editor = users(:editor)
  end
  
  def test_admin_user_has_admin_role
    assert(@admin.admin_role?, "@admin should have admin_role?")
  end  

  def test_editor_user_has_editor_role
    assert(@editor.editor_role?, "@editor should have editor_role?")
  end
  
  def test_owner_is_true_for_owner
    assert(@exhibit.owner?(@owner), "owner? should have responded true.")
  end
  
  def test_owner_is_true_for_owner_id
    assert(@exhibit.owner?(@owner.id), "owner? should have responded true.")
  end
  
  def test_owner_is_false_for_non_owner
    user = User.new
    user.save
    assert( !@exhibit.owner?(user), "owner? should have responded false.")
  end
  
  def test_owner_is_false_for_non_owner_id
    assert( !@exhibit.owner?(@owner.id + 1), "owner? should have responded false.")
  end
  
  # test permissions
  def test_owner_and_admin_can_view_exhibit
    assert @exhibit.viewable_by?(@owner)
    assert @exhibit.viewable_by?(@admin)
  end
  
  def test_non_owner_can_not_view_unshared_exhibit
    assert(!@exhibit.viewable_by?(User.new), "Non-owner should not be able to view unshared exhibit.")
  end
  
  def test_owner_and_admin_can_update_exhibit
    assert(@exhibit.updatable_by?(@owner), "Owner should be able to update exhibit.")
    assert(@exhibit.updatable_by?(@admin), "Admin should be able to update exhibit.")
  end
  
  def test_non_owner_can_not_update_exhibit
    assert(!@exhibit.updatable_by?(User.new), "Non-owner should not be able to update exhibit.")
  end
  
  def test_owner_and_admin_can_delete_exhibit
    assert(@exhibit.deletable_by?(@owner), "Owner should be able to delete exhibit")
    assert(@exhibit.deletable_by?(@admin), "Admin should be able to delete exhibit")
  end
  
  def test_non_owner_can_not_delete_exhibit
    assert(!@exhibit.deletable_by?(User.new), "Non-owner should not be able to delete another's exhibit.")
  end
    
  def test_anyone_can_view_shared_exhibit
    @exhibit.share!
    assert(@exhibit.viewable_by?(User.new), "Anyone should be able to view a shared exhibit.")
  end
  
  def test_owner_and_admin_can_share_exhibit
    assert(@exhibit.sharable_by?(@owner), "Owner should be able to share the exhibit.")
    assert(@exhibit.sharable_by?(@admin), "Admin should be able to share the exhibit.")
  end
  
  def test_others_cannot_share_exhibit
    assert(!@exhibit.sharable_by?(User.new), "Others should not be able to share the exhibit.")
    assert(!@exhibit.sharable_by?(Guest.new), "Guest should not be able to share the exhibit.")
  end
    
end
