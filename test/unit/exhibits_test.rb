require File.dirname(__FILE__) + '/../test_helper'

class ExhibitsTest < Test::Unit::TestCase
  fixtures :exhibits, :exhibited_resources, :exhibited_sections, :users
  fixtures :licenses, :exhibit_section_types, :exhibit_types
  
  # Note: only using fixtures for more static data.
  def setup
    @st = exhibit_section_types(:citation)
    @et = exhibit_types(:annotated_bibliography)
    @exhibit = exhibits(:dang)
    @owner = users(:exhibit_owner)
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
  def test_owner_can_view_exhibit
    assert @exhibit.viewable_by?(@owner)
  end
  
  def test_non_owner_can_not_view_unshared_exhibit
    assert(!@exhibit.viewable_by?(User.new), "Non-owner should not be able to view unshared exhibit.")
  end
  
  def test_owner_can_update_exhibit
    assert(@exhibit.updatable_by?(@owner), "Owner should be able to update exhibit.")
  end
  
  def test_non_owner_can_not_update_exhibit
    assert(!@exhibit.updatable_by?(User.new), "Non-owner should not be able to update exhibit.")
  end
  
  def test_owner_can_delete_exhibit
    assert(@exhibit.deletable_by?(@owner), "Owner should be able to delete exhibit")
  end
  
  def test_non_owner_can_not_delete_exhibit
    assert(!@exhibit.deletable_by?(User.new), "Non-owner should not be able to delete another's exhibit.")
  end
  
  def test_anyone_can_view_shared_exhibit
    @exhibit.shared = true
    assert(@exhibit.viewable_by?(User.new), "Anyone should be able to view a shared exhibit.")
  end

end
