require File.dirname(__FILE__) + '/../test_helper'

class InterpretationsTest < Test::Unit::TestCase
  fixtures :interpretations, :users

  def test_cannot_duplicate_uri_and_username
    i1 = Interpretation.create(:user_id => 1, :object_uri => "foo")
    assert i1.valid?
    i2 = Interpretation.create(:user_id => 1, :object_uri => "foo")
    assert !i2.valid?
  end
  
  def test_can_duplicate_uri_with_different_users
    i1 = Interpretation.create(:user_id => 1, :object_uri => "foo")
    assert i1.valid?
    i2 = Interpretation.create(:user_id => 2, :object_uri => "foo")
    assert i2.valid?
  end

  def test_can_duplicate_user_with_different_uris
    i1 = Interpretation.create(:user_id => 1, :object_uri => "foo")
    assert i1.valid?
    i2 = Interpretation.create(:user_id => 1, :object_uri => "baz")
    assert i2.valid?
  end
end
