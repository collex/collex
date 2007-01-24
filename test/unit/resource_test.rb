require File.dirname(__FILE__) + '/../test_helper'

class ResourceTest < Test::Unit::TestCase
#   fixtures :resources

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def test_mla_authors_should_format_single_author
    @prop_1 = Property.create(:name => "role_AUT", :value => "First Last")
    @res = Resource.create
    @res.properties << @prop_1
    assert_equal(1, @res.properties.size)
    
    expected = "Last, First."
    assert_equal(expected, @res.mla_authors)
    
    @res.properties.first.value = "Last, First"
    @res.save
    assert_equal(expected, @res.mla_authors)
  end
  
  def test_mla_authors_should_format_two_authors_with_and
    @prop_1 = Property.create(:name => "role_AUT", :value => "First Last")
    @prop_2 = Property.create(:name => "role_AUT", :value => "Last-Name, Second")
    @res = Resource.create
    @res.properties << @prop_1
    @res.properties << @prop_2
    assert_equal(2, @res.properties.size)
    
    expected = "Last, First and Last-Name, Second."
    assert_equal(expected, @res.mla_authors)
    
    @res.properties.first.value = "Last, First"
    @res.save
    assert_equal(expected, @res.mla_authors)
  end
  
  def test_mla_authors_should_format_many_authors_with_commas_and_and
    @prop_1 = Property.create(:name => "role_AUT", :value => "First Last")
    @prop_2 = Property.create(:name => "role_AUT", :value => "Last-Name, Second")
    @prop_3 = Property.create(:name => "role_AUT", :value => "T.N. Surname")
    @res = Resource.create
    @res.properties << @prop_1
    @res.properties << @prop_2
    @res.properties << @prop_3
    assert_equal(3, @res.properties.size)
    
    expected = "Last, First, Last-Name, Second, and Surname, T.N."
    assert_equal(expected, @res.mla_authors)
    
    @res.properties.first.value = "Last, First"
    @res.save
    assert_equal(expected, @res.mla_authors)
  end
end
