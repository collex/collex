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

class CachedResourceTest < ActiveSupport::TestCase
  fixtures :users, :tags, :tagassigns, :cached_resources, :cached_properties, :collected_items

  def setup
    @paul = User.find(23)
    @dave = User.find(99)
  end
  
  def test_tag_cloud
    tags = CachedResource.get_tag_cloud_info(nil)
    assert_equal 3, tags[:cloud_freq].length
    assert_equal 'daves_tag', tags[:cloud_freq][0][0]
    assert_equal 1, tags[:cloud_freq][0][1]
    assert_equal 'good', tags[:cloud_freq][1][0]
    assert_equal 2, tags[:cloud_freq][1][1]
    assert_equal 'pauls_tag', tags[:cloud_freq][2][0]
    assert_equal 1, tags[:cloud_freq][2][1]

    tags =  CachedResource.get_tag_cloud_info(@paul)
    assert_equal 2, tags[:cloud_freq].length
    assert_equal 'good', tags[:cloud_freq][0][0]
    assert_equal 1, tags[:cloud_freq][0][1]
    assert_equal 'pauls_tag', tags[:cloud_freq][1][0]
    assert_equal 1, tags[:cloud_freq][1][1]

    tags =  CachedResource.get_tag_cloud_info(@dave)
    assert_equal 2, tags[:cloud_freq].length
    assert_equal 'daves_tag', tags[:cloud_freq][0][0]
    assert_equal 1, tags[:cloud_freq][0][1]
    assert_equal 'good', tags[:cloud_freq][1][0]
    assert_equal 1, tags[:cloud_freq][1][1]
  end

  def test_get_hit_from_uri
    # called by all the ajax calls to add a tag, change annotation, etc.
    hit = CachedResource.get_hit_from_uri("http://resource/2/dave")
    assert_equal "http://resource/2/dave", hit['uri']
    hit = CachedResource.get_hit_from_uri("bad_uri")
    assert_nil hit
  end
  
#  def test_get_all_collections
#    # Pass in the actual user object (not just the user name), and get back an array of results. Each result is a hash of all the properties that were cached.
#    colls = CachedResource.get_all_collections(@paul)
#    assert_equal 3, colls.length
#    assert_equal 1, colls[0]['thumbnail'].length
#    assert_equal "http://resource/1/paul", colls[0]['uri']
#    assert_equal 1, colls[1]['thumbnail'].length
#    assert_equal "http://resource/3/both", colls[1]['uri']
#    assert_equal 1, colls[1]['thumbnail'].length
#    assert_equal "http://resource/4/paul_untagged", colls[2]['uri']
#  end
  
  def test_get_hits_for_tag
    hits = CachedResource.get_hits_for_tag("good", @paul)
    assert_equal 1, hits.length
    assert_equal "http://resource/3/both", hits[0]['uri']
    hits = CachedResource.get_hits_for_tag("bad", nil)
    assert_equal 0, hits.length
    hits = CachedResource.get_hits_for_tag("bad", @paul)
    assert_equal 0, hits.length
    hits = CachedResource.get_hits_for_tag("daves_tag", @paul)
    assert_equal 0, hits.length
    hits = CachedResource.get_hits_for_tag("daves_tag", @dave)
    assert_equal 1, hits.length
    assert_equal "http://resource/2/dave", hits[0]['uri']
    hits = CachedResource.get_hits_for_tag("good", nil)
  end
  
#  def test_get_all_untagged
#    hits = CachedResource.get_all_untagged(nil)
#    assert_equal 0, hits.length
#    hits = CachedResource.get_all_untagged(@paul)
#    assert_equal 1, hits.length
#    assert_equal "http://resource/4/paul_untagged", hits[0]['uri']
#  end
  
  def test_recache_properties
    cached_resources = CachedResource.find(:all)
    assert_equal 5, cached_resources.length

    cached_properties = CachedProperty.find(:all)
    assert_equal 15, cached_properties.length
#    CachedProperty.delete_all()
#    cached_properties = CachedProperty.find(:all)
#    assert_equal 0, cached_properties.length

    # 3 of the resources exist, and 2 don't. The 2 that don't should keep their original info.
    cached_resources.each do |cr|
      cr.recache_properties()
    end
    
    cached_resources = CachedResource.find(:all)
    assert_equal 5, cached_resources.length

    cached_properties = CachedProperty.find(:all)
    assert_equal 20, cached_properties.length
    assert_equal 'stale', cached_properties[19]['name']
  end
  
end
