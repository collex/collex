##########################################################################
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
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

class SolrResourceTest < Test::Unit::TestCase
  fixtures :sites
  
  URI = "http://some/fake/uri"
  URLS = [URI << ".html"]
  THUMBNAIL = "http://some/fake/uri/img/thumbnail.png"
  USERNAME = "some_user"
  
  MLTS = [{"uri"=>"http://rotunda.upress.virginia.edu/Arnold/V3P176D2", "title"=>["Algernon Charles Swinburne to Matthew Arnold"], "archive"=>"rotunda_arnold", "date_label"=>["9 October 1867"], "url"=>["http://rotunda.upress.virginia.edu/Arnold/display.xqy?letter=V3P176D2"], "genre"=>["Primary", "Letters"], "year"=>["1867"], "source"=>["The Letters of Matthew Arnold (ISBN: 0813916518)"], "agent"=>["Algernon Charles Swinburne", "Cecil Y. Lang", "University of Virginia Press"]}, 
        {"uri"=>"http://rotunda.upress.virginia.edu/Arnold/V3P178D1", "title"=>["Matthew Arnold to Algernon Charles Swinburne"], "archive"=>"rotunda_arnold", "date_label"=>["10 October 1867"], "url"=>["http://rotunda.upress.virginia.edu/Arnold/display.xqy?letter=V3P178D1"], "genre"=>["Primary", "Letters"], "year"=>["1867"], "source"=>["The Letters of Matthew Arnold (ISBN: 0813916518)"], "agent"=>["Matthew Arnold", "Cecil Y. Lang", "University of Virginia Press"]}]
  
  COLLECTION_INFO = {'users' => ["user_one", "user_two"]}
  
  class CollexEngine
    def objects_for_uris(uris, user=nil)
      if(uris == [URI])
        [{"thumbnail" => THUMBNAIL, "uri" => URI, "title"=>["First Title"], "archive"=>"swinburne", "date_label" => ["1865"], "url" => URLS, "genre"=>["Poetry", "Primary"], "year"=>["1865"], "agent"=>["Swinburne, Algernon Charles, 1837-1909", "Chatto"]}]
      else
        []
      end
    end  
    def object_detail(objid, user)
      document = {"thumbnail" => THUMBNAIL, "uri" => URI, "title"=>["First Title"], "archive"=>"swinburne", "date_label" => ["1865"], "url" => URLS, "genre"=>["Poetry", "Primary"], "year"=>["1865"], "agent"=>["Swinburne, Algernon Charles, 1837-1909", "Chatto"]}    
      mlt = MLTS
      collection_info = COLLECTION_INFO
      if(objid == URI)
        return [document, mlt, collection_info]
      else
        return [nil, nil, nil]
      end
    end
  end
  
  def SolrResource.solr
    CollexEngine.new
  end
  
  AUT = "AUT"
  EDT = "EDT"
  def setup
    @r = SolrResource.new :uri => URI
    @jerry = SolrProperty.new(:name => "name", :value => "Jerry McGann")
    @aut = SolrProperty.new(:name => "role_#{AUT}", :value => "Dana Wheeles")
    @edt = SolrProperty.new(:name => "role_#{EDT}", :value => "Bethany Nowviskie")
  end


  def test_uri_was_populated
    assert_equal(URI, @r.uri)
  end
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
    assert_equal(@jerry.value, @r.name)
  end
  
  def test_properties_accessable_directly_by_plural_name
    @r.properties << @jerry
    assert_equal(@jerry.value, @r.names[0])
  end
  
  def test_roles_with_agents_returns_list_of_three_letter_name_and_agent_name
    @r.properties << @aut
    @r.properties << @edt
    assert_equal(AUT, @r.roles_with_agents[0].name)
    assert_equal(EDT, @r.roles_with_agents[1].name)
    assert_equal(@aut.value, @r.roles_with_agents[0].value)
    assert_equal(@edt.value, @r.roles_with_agents[1].value)
  end
  
  def test_non_property_returns_empty_string
    assert_equal("", @r.bogus_property)
    assert(@r.bogus_property.blank?, "Bogus Property should be blank.")
    assert(@r.bogus_props.blank?, "Bogus Props should be blank.")
  end
  
  def test_find_by_uri_raises_argument_error_when_none
    assert_raise(ArgumentError) { SolrResource.find_by_uri() }
  end
  
  def test_find_by_uri_raises_argument_error_for_missing_uri_or_uri_array
    assert_raise(ArgumentError) { SolrResource.find_by_uri({:user => USERNAME}) }
  end
  
  def test_find_by_uri_with_string_returns_nil_if_none_found
    assert_nil(SolrResource.find_by_uri("somebaduri"))
  end
  
  def test_find_by_uri_with_array_returns_empty_array_if_none_found
    assert_equal([], SolrResource.find_by_uri(["baduri", "anotherbaduri"]))
  end
  
  def test_find_by_uri_with_string_gets_one_resource_with_mlt_and_users
    res = SolrResource.find_by_uri(URI)
    assert_kind_of(SolrResource, res)
    assert_equal(URI, res.uri)
    assert_equal(URLS[0], res.url)
    
    assert_equal(MLTS.size, res.mlt.size)
    res.mlt.each_with_index do |item, i|
      assert_kind_of(SolrResource, item)
      assert_equal(MLTS[i]['uri'], item.uri)
      assert_equal(MLTS[i]['title'][0], item.titles[0])
    end
    
    assert_equal(COLLECTION_INFO['users'].size, res.users.size)
    assert_equal(COLLECTION_INFO['users'][0],res.users[0])
    assert_equal(COLLECTION_INFO['users'][1],res.users[1])
  end
  
  def test_find_by_uri_with_array_gets_resource_array_with_mlt_and_users
    ra = SolrResource.find_by_uri([URI])
    assert_equal(1, ra.size)
    assert_kind_of(Array, ra)
    assert_kind_of(SolrResource, ra[0])
    assert_equal(URI, ra[0].uri)
    assert_equal(URLS[0], ra[0].url)
  end
  
  def test_returns_proper_site_object_for_archive_code
    res = SolrResource.find_by_uri(URI)
    assert_equal(Site.find_by_code('swinburne'), res.site)
  end
  
end
