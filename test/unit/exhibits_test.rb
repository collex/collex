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
end
