require File.dirname(__FILE__) + '/../test_helper'

class ExhibitedResourceTest < Test::Unit::TestCase
  URI = "http://test/uri"
  TITLE = "Test Title"
  GENRE_1 = "Primary"
  GENRE_2 = "Poetry"
  
  def setup
    @resource = SolrResource.new(:uri => URI)
    @title_prop = SolrProperty.new(:name => 'title', :value => TITLE)
    @genre_1_prop = SolrProperty.new(:name => 'genre', :value => GENRE_1)
    @genre_2_prop = SolrProperty.new(:name => 'genre', :value => GENRE_2)
    @resource.properties = [@title_prop, @genre_1_prop, @genre_2_prop]
    
    @er = ExhibitedResource.new(:uri => URI)
    @er.instance_variable_set("@resource", @resource)
  end
  
  def test_sanity
    assert_equal(URI, @resource.uri)
    assert_equal(URI, @er.uri)
  end
  
  def test_resource_properties_available_as_er_properties
    assert_equal(@resource.title, @er.title)
    assert_equal(@resource.genre, @er.genre)
    assert_equal(@resource.genres, @er.genres)
  end
end
