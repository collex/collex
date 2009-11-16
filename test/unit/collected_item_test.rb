##########################################################################
# Copyright 2009 Applied Research in Patacriticism and the University of Virginia
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

# the following tables are intertwined and need to be tested to see if there is are any side effects:
# tags, collected_items_tags, cached_properties, cached_resources
# the users table is used, but is never modified. It requires two users to have been set up.

class CollectedItemTest < ActiveSupport::TestCase
    fixtures :collected_items
    fixtures :tagassigns
    fixtures :tags
    fixtures :cached_resources
    fixtures :cached_properties
    fixtures :users

  def setup
       get_baseline()
	    @solr = CollexEngine.new()
  end

  def get_baseline
    @all_tags_start = Tag.find(:all)
    @all_tagassigns_start = Tagassign.find(:all)
    @all_cached_properties_start = CachedProperty.find(:all)
    @all_cached_resources_start = CachedResource.find(:all)
    @all_collected_items_start = CollectedItem.find(:all)
  end

  def get_current
    @all_tags_current = Tag.find(:all)
    @all_tagassigns_current = Tagassign.find(:all)
    @all_cached_properties_current = CachedProperty.find(:all)
    @all_cached_resources_current = CachedResource.find(:all)
    @all_collected_items_current = CollectedItem.find(:all)
  end

  def get_user(id)
    return User.find(id)
  end
  
  def collect_a_text(user_id, uri, wants_nil)
    begin
      new_item = CollectedItem.collect_item(get_user(user_id), uri, @solr.get_object( uri ))
    rescue Exception => msg
      return if wants_nil
      assert false, msg
    end
    if (wants_nil)
      assert_nil(new_item, "Should not have added the item")
    else
      assert_equal(user_id, new_item.user_id, "wrong user stored with collected item")
      assert_equal(uri, new_item.cached_resource.uri, "Wrong uri stored with collected item")
      assert_nil(new_item.annotation, "Should not set an annotation by default")
      #assert_equal(0, new_item.tags.length, "Should not have any tags by default")
    end
  end
  
  def check_if_collect_added()
    get_current()
    
    assert_equal(@all_collected_items_start.length + 1, @all_collected_items_current.length, "A new collected item record should have been created")
    assert_equal(@all_cached_resources_start.length + 1, @all_cached_resources_current.length, "The uri should have been cached when collecting")
    assert_equal(@all_cached_properties_start.length + 12, @all_cached_properties_current.length, "The properties of the uri should have been cached when the uri was cached")
    assert_equal(@all_tags_start.length, @all_tags_current.length, "The tags table should not have changed")
    assert_equal(@all_tagassigns_start.length,  @all_tagassigns_current.length, "The tags/collected items jion should not have changed")
  end
  
  def check_if_equal_to_current
    all_tags = Tag.find(:all)
    all_tagassigns = Tagassign.find(:all)
    all_cached_properties = CachedProperty.find(:all)
    all_cached_resources = CachedResource.find(:all)
    all_collected_items = CollectedItem.find(:all)
    
    assert_equal(@all_tags_current, all_tags, "Should not have added tags")
    assert_equal(@all_tagassigns_current, all_tagassigns, "Should not have added collect/tag join")
    assert_equal(@all_cached_properties_current, all_cached_properties, "Should not have added cached properties")
    assert_equal(@all_cached_resources_current, all_cached_resources, "Should not have added cached resources")
    assert_equal(@all_collected_items_current, all_collected_items, "Should not have added collected item")
  end
  
  def check_if_equal_to_baseline()
    check_if_equal_to_baseline_except_cache()

    all_cached_properties = CachedProperty.find(:all)
    all_cached_resources = CachedResource.find(:all)
    
    assert_equal(@all_cached_properties_start, all_cached_properties, "Should not have added cached properties")
    assert_equal(@all_cached_resources_start, all_cached_resources, "Should not have added cached resources")
  end

  def check_if_equal_to_baseline_except_cache()
     all_tags = Tag.find(:all)
    all_tagassigns = Tagassign.find(:all)
    all_collected_items = CollectedItem.find(:all)
    
    assert_equal(@all_tags_start, all_tags, "Should not have added tags")
    assert_equal(@all_tagassigns_current, all_tagassigns, "Should not have added collect/tag join")
    assert_equal(@all_collected_items_start, all_collected_items, "Should not have added collected item")
  end

  #####################################################
  # collect tests
  #####################################################
  def test_collect_item
    # just add an item as collected
    get_baseline()
    collect_a_text(1, "http://some/fake/uri", false)
    check_if_collect_added()
   end
  
  def test_collect_twice
    # ok if different user, not ok if same user
    get_baseline()
    collect_a_text(1, "http://some/fake/uri", false)
    check_if_collect_added()

    collect_a_text(1, "http://some/fake/uri", true)
    check_if_equal_to_current()
   end

  def test_collect_second_item
    get_baseline()
    collect_a_text(1, "http://some/fake/uri", false)
    check_if_collect_added()

    get_baseline()
    collect_a_text(1, "http://some/fake/uri2", false)
    check_if_collect_added()
  end
  
  def test_delete_collected_item
    get_baseline()
    collect_a_text(1, "http://some/fake/uri", false)
    check_if_collect_added()
    
    CollectedItem.remove_collected_item(get_user(1), "http://some/fake/uri")
    check_if_equal_to_baseline_except_cache()

    # uncollecting an object that is already not collected should fail silently.
    CollectedItem.remove_collected_item(get_user(1), "http://some/fake/uri")
  end
  
  #####################################################
  # annotation tests
  #####################################################
  def test_add_annotation
     user = get_user(1)
 
    note_str = "This is my first annotation"
    CollectedItem.set_annotation(user, "http://some/fake/uri", note_str)
    # the item should not be annotated but should fail silently

    collect_a_text(1, "http://some/fake/uri", false)
    item = CollectedItem.get(user, "http://some/fake/uri")
    assert_nil(item.attributes['annotation'], "Item should not have annotation")

    CollectedItem.set_annotation(user, "http://some/fake/uri", note_str)
    item = CollectedItem.get(user, "http://some/fake/uri")
    assert_equal(note_str, item.attributes['annotation'], "annotation should have been set")
  end
  
  def test_change_annotation
    collect_a_text(1, "http://some/fake/uri", false)
    note_str = "This is my first annotation"
    CollectedItem.set_annotation(get_user(1), "http://some/fake/uri", note_str)
    item = CollectedItem.get(get_user(1), "http://some/fake/uri")
    assert_equal(note_str, item.attributes['annotation'], "annotation should have been set")

    note_str = "I've changed this"
    CollectedItem.set_annotation(get_user(1), "http://some/fake/uri", note_str)
    item = CollectedItem.get(get_user(1), "http://some/fake/uri")
    assert_equal(note_str, item.attributes['annotation'], "annotation should have been set")

    note_str = ""
    CollectedItem.set_annotation(get_user(1), "http://some/fake/uri", note_str)
    item = CollectedItem.get(get_user(1), "http://some/fake/uri")
    assert_equal(note_str, item.attributes['annotation'], "annotation should have been set")
  end
  
  #####################################################
  # tag tests
  #####################################################
  def test_add_tag
    user = get_user(1)
    tag_str = "interesting"
    uri = "http://some/fake/uri"
 
    # first be sure that we can't add a tag if the item isn't collected.
    CollectedItem.add_tag(user, uri, tag_str)
    # this should fail silently
    
    # add the tag and be sure it's added
    collect_a_text(1, uri, false)
    CollectedItem.add_tag(user, uri, tag_str)
    item = CollectedItem.get(user, uri)
    tags = item.tags
    assert_equal(1, tags.length, "Expected one tag to be returned")
    assert_equal(tag_str, tags[0].name, "Wrong tag saved")
    
    # now see if we can get the collected item from the tag
    tag_rec = Tag.find_by_name(tag_str)
    col = tag_rec.collected_items
    assert_equal(1, col.length)
    res = col[0].cached_resource
    assert_equal(uri, res.uri)
    
    # there should be just one item in the join table
    join = Tagassign.find(:all)
    assert_equal(@all_tagassigns_start.length + 1, join.length)
  end
  
  def test_add_same_tag_again
    get_baseline()
   # this should just ignore the new entry
    test_add_tag()

    user = get_user(1)
    tag_str = "interesting"
    uri = "http://some/fake/uri"
    # add the tag again and be sure nothing's different
    CollectedItem.add_tag(user, uri, tag_str)
    item = CollectedItem.get(user, uri)
    tags = item.tags
    assert_equal(1, tags.length, "Expected one tag to be returned")
    assert_equal(tag_str, tags[0].name, "Wrong tag saved")
    
    # now see if we can get the collected item from the tag
    tag_rec = Tag.find_by_name(tag_str)
    col = tag_rec.collected_items
    assert_equal(1, col.length)
    res = col[0].cached_resource
    assert_equal(uri, res.uri)
    
    # there should be just one item in the join table
    join = Tagassign.find(:all)
    assert_equal(@all_tagassigns_start.length + 1, join.length)
  end
  
  def test_add_second_tag
   get_baseline()
    test_add_tag()

    user = get_user(1)
    tag_str = "another"
    uri = "http://some/fake/uri"
    # add the second tag and be sure it's in there
    CollectedItem.add_tag(user, uri, tag_str)
    item = CollectedItem.get(user, uri)
    tags = item.tags
    assert_equal(2, tags.length, "Expected both tags to be returned")
    assert_equal("interesting", tags[0].name, "Wrong tag saved")
    assert_equal(tag_str, tags[1].name, "Wrong tag saved")
    
    # now see if we can get the collected item from the tag
    tag_rec = Tag.find_by_name(tag_str)
    col = tag_rec.collected_items
    assert_equal(1, col.length)
    res = col[0].cached_resource
    assert_equal(uri, res.uri)
    
    # there should be two items in the join table
    join = Tagassign.find(:all)
    assert_equal(@all_tagassigns_start.length + 2, join.length)
    assert_equal("interesting", join[@all_tagassigns_start.length + 0].tag.name, "wrong tag in join table")
    assert_equal(tag_str, join[@all_tagassigns_start.length + 1].tag.name, "wrong tag in join table")
    assert_equal(uri, join[@all_tagassigns_start.length + 0].collected_item.cached_resource.uri, "wrong uri")
    assert_equal(uri, join[@all_tagassigns_start.length + 1].collected_item.cached_resource.uri, "wrong uri")
    
  end

  def test_add_tag_to_second_item
    # add the second tag and be sure it's in there
    test_collect_second_item()

    user = get_user(1)
    tag_str = "first"
    uri1 = "http://some/fake/uri"
    CollectedItem.add_tag(user, uri1, tag_str)
    uri2 = "http://some/fake/uri2"
    CollectedItem.add_tag(user, uri2, tag_str)
    
    item = CollectedItem.get(user, uri1)
    tags = item.tags
    assert_equal(1, tags.length, "Expected one tag to be returned")
    assert_equal(tag_str, tags[0].name, "Wrong tag saved")

    item = CollectedItem.get(user, uri2)
    tags = item.tags
    assert_equal(1, tags.length, "Expected one tag to be returned")
    assert_equal(tag_str, tags[0].name, "Wrong tag saved")
    
    # now see if we can get the collected item from the tag
    tag_rec = Tag.find_by_name(tag_str)
    col = tag_rec.collected_items
    assert_equal(2, col.length)
    res = col[0].cached_resource
    assert_equal(uri1, res.uri)
    res = col[1].cached_resource
    assert_equal(uri2, res.uri)
    
    # there should be two items in the join table
    join = Tagassign.find(:all)
    assert_equal(@all_tagassigns_start.length + 2, join.length)
    assert_equal(tag_str, join[@all_tagassigns_start.length + 0].tag.name, "wrong tag in join table")
    assert_equal(tag_str, join[@all_tagassigns_start.length + 1].tag.name, "wrong tag in join table")
    assert_equal(uri1, join[@all_tagassigns_start.length + 0].collected_item.cached_resource.uri, "wrong uri")
    assert_equal(uri2, join[@all_tagassigns_start.length + 1].collected_item.cached_resource.uri, "wrong uri")
    
  end

  def test_delete_a_tag_with_two_collected_items
    test_add_tag_to_second_item()
    
    user = get_user(1)
    tag_str = "first"
    uri = "http://some/fake/uri"
    uri2 = "http://some/fake/uri2"
    CollectedItem.delete_tag(user, uri, tag_str)

    item = CollectedItem.get(user, uri)
    tags = item.tags
    assert_equal(0, tags.length, "Expected no tags to be returned")
    
    item = CollectedItem.get(user, uri2)
    tags = item.tags
    assert_equal(1, tags.length, "Expected one tag to be returned")
    assert_equal(tag_str, tags[0].name, "Wrong tag saved")
    
    # now see if we can get the collected item from the tag
    tag_rec = Tag.find_by_name(tag_str)
    col = tag_rec.collected_items
    assert_equal(1, col.length)
    res = col[0].cached_resource
    assert_equal(uri2, res.uri)
    
    # there should be just one item in the join table
    join = Tagassign.find(:all)
    assert_equal(@all_tagassigns_start.length + 1, join.length)
  end
  
  def test_delete_a_tag_with_one_collected_item
    test_add_tag()
    user = get_user(1)
    tag_str = "interesting"
    uri = "http://some/fake/uri"
    CollectedItem.delete_tag(user, uri, tag_str)
    
    item = CollectedItem.get(user, uri)
    tags = item.tags
    assert_equal(0, tags.length, "Expected no more tags to be returned")
    
    # now see if we can get the collected item from the tag
    tag_rec = Tag.find_by_name(tag_str)
    assert_nil(tag_rec, "The tag should have been deleted")
    
    # there should be nothing in the join table
    join = Tagassign.find(:all)
    assert_equal(@all_tagassigns_start.length + 0, join.length)
  end

  def test_delete_a_collected_item_that_has_a_tag
    #test both if that is the last reference to the tag, and if there is another reference
    test_add_tag_to_second_item()
    
    user = get_user(1)
    tag_str = "first"
    uri = "http://some/fake/uri"
    uri2 = "http://some/fake/uri2"

    # remove the first one
    CollectedItem.remove_collected_item(user, uri)

    # there is still one reference to the tag. Be sure that exists
    tag_rec = Tag.find_by_name(tag_str)
    col = tag_rec.collected_items
    assert_equal(1, col.length)
    res = col[0].cached_resource
    assert_equal(uri2, res.uri)

    join = Tagassign.find(:all)
    assert_equal(@all_tagassigns_start.length + 1, join.length)
    assert_equal(uri2, join[@all_tagassigns_start.length + 0].collected_item.cached_resource.uri)
    
    # remove the second one
    CollectedItem.remove_collected_item(user, uri2)

    # there should be no references left
    tag_rec = Tag.find_by_name(tag_str)
    col = tag_rec.collected_items
    assert_equal(0, col.length)

    join = Tagassign.find(:all)
    assert_equal(@all_tagassigns_start.length + 0, join.length)
  end
 
  #####################################################
  # multiple user tests
  #####################################################
  def test_collect_same_item_as_different_user
    get_baseline()
    user1 = get_user(1)
    user2 = get_user(2)
    uri = "http://some/fake/uri"
    CollectedItem.collect_item(user1, uri, @solr.get_object( uri ))
    CollectedItem.collect_item(user2, uri, @solr.get_object( uri ))

    # now there should be two items in the collection
    get_current()
    
    assert_equal(@all_collected_items_start.length + 2, @all_collected_items_current.length, "A new collected item record should have been created")
    assert_equal(@all_cached_resources_start.length + 1, @all_cached_resources_current.length, "The uri should have been cached when collecting")
    assert_equal(@all_cached_properties_start.length + 12, @all_cached_properties_current.length, "The properties of the uri should have been cached when the uri was cached")
    assert_equal(@all_tags_start.length, @all_tags_current.length, "The tags table should not have changed")
    assert_equal(@all_tagassigns_start.length,  @all_tagassigns_current.length, "The tags/collected items jion should not have changed")
  end
  
  def test_add_tag_that_other_user_used
    get_baseline()
    user1 = get_user(1)
    user2 = get_user(2)
    uri = "http://some/fake/uri"
    tag_str = "interesting"
    CollectedItem.collect_item(user1, uri, @solr.get_object( uri ))
    CollectedItem.collect_item(user2, uri, @solr.get_object( uri ))
    CollectedItem.add_tag(user1, uri, tag_str)
    CollectedItem.add_tag(user2, uri, tag_str)

    # now there should be one tag, two joins, and two collected items
    tags = Tag.find(:all)
    assert_equal(@all_tags_start.length+1, tags.length)
    assert_equal(tag_str, tags[@all_tags_start.length].name)
    col = tags[@all_tags_start.length].collected_items
    assert_equal(2, col.length)
    assert_equal(uri, col[0].cached_resource.uri)
    assert_equal(uri, col[1].cached_resource.uri)

    join = Tagassign.find(:all)
    assert_equal(@all_tagassigns_start.length + 2, join.length)
    assert_equal(uri, join[@all_tagassigns_start.length + 0].collected_item.cached_resource.uri)
    assert_equal(tag_str, join[@all_tagassigns_start.length + 0].tag.name)
    assert_equal(uri, join[@all_tagassigns_start.length + 1].collected_item.cached_resource.uri)
    assert_equal(tag_str, join[@all_tagassigns_start.length + 1].tag.name)
    
    all_items = CollectedItem.find(:all)
    assert_equal(@all_collected_items_start.length+2, all_items.length, "Should be two items in the collection")
    assert_equal(uri, all_items[@all_collected_items_start.length+0].cached_resource.uri)
    assert_equal(uri, all_items[@all_collected_items_start.length+1].cached_resource.uri)
  end
 
end
