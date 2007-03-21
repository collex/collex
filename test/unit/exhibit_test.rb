require File.dirname(__FILE__) + '/../test_helper'

class ExhibitTest < Test::Unit::TestCase
  fixtures :exhibits
  
  def setup
    @exhibit = Exhibit.new
    @exhibit.license_id = 2
    @exhibit.exhibit_type_id = 2
    @exhibit.title = "Title"
    @user = User.new
    @user.save!
    @exhibit.user = @user
    @exhibit.save!
  end

  def test_owner_is_true_for_user_object
    assert(@exhibit.owner?(@user), "User did not equal owner for exhibit.")
  end
  
  def test_owner_is_true_for_user_id
    assert(@exhibit.owner?(@user.id), "user_id did not equal owner for exhibit.")
  end
  
  def test_bad_owner_is_false_for_user_object
    assert(!@exhibit.owner?(User.new), "User should not be owner")
  end
  
  def test_bad_owner_is_false_for_user_id
    assert(!@exhibit.owner?(-1), "User should not be owner")
  end
end
