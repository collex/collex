require File.dirname(__FILE__) + '/../test_helper'

class SolrResourceTest < Test::Unit::TestCase
  def setup
    @r = SolrResource.new :uri => "http://some/fake/uri"
    @jerry = SolrProperty.new(:name => "name", :value => "Jerry McGann")
  end


  # Replace this with your real tests.
  def test_properties_exist_and_are_blank_for_raw_instance
    assert(@r.properties, "There should be a properties array.")
    assert(@r.properties.blank?, "Properties should be blank.")
  end
  
  def test_properties_are_writable_as_list
    @r.properties << @jerry
    assert_equal(1, @r.properties.size)
  end
  
  def test_properties_accessable_directly_by_name
    @r.properties << @jerry
    assert_equal(@jerry, @r.name)
  end
  
  def test_properties_accessable_directly_by_plural_name
    @r.properties << @jerry
    assert_equal(@jerry, @r.names[0])
  end
  
end
