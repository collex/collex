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

class CollectedItem < ActiveRecord::Base
  belongs_to :cached_resource
  belongs_to :user
  
  def self.get_all_users_collections(user)
    return CollectedItem.find_all_by_user_id(user.id)
  end

  # This returns the collected objects as a json string
  def self.get_collected_object_array(user_id)
    objs = CollectedItem.find_all_by_user_id(user_id)
    str = ""
    objs.each {|obj|
      hit = CachedResource.get_hit_from_resource_id(obj.cached_resource_id)
      if hit != nil
        image = CachedResource.get_thumbnail_from_hit(hit)
        image = DEFAULT_THUMBNAIL_IMAGE_PATH if image == "" || image == nil
        if str != ""
          str += ",\n"
        end
        str += "{ uri: '#{hit['uri']}', thumbnail: '#{image}', title: '#{self.escape_quote(hit['title'])}'}"
      end
    }
    
    return '[' + str + ']'
  end

  # this returns the collected objects as a ruby array
  def self.get_collected_object_ruby_array(user_id)
    objs = CollectedItem.find_all_by_user_id(user_id)
    arr = []
    objs.each {|obj|
      hit = CachedResource.get_hit_from_resource_id(obj.cached_resource_id)
      if hit != nil
        image = CachedResource.get_thumbnail_from_hit(hit)
        image = DEFAULT_THUMBNAIL_IMAGE_PATH if image == "" || image == nil
        arr.insert(-1, { :uri => hit['uri'], :thumbnail => image, :title => self.escape_quote(hit['title']) })
      end
    }
    
    return arr
  end

  def self.escape_quote(arr)
    return '' if arr == nil
    return '' if arr[0] == nil
    str = arr[0].gsub("\n", " ").gsub("\r", " ")
    return str.gsub("'", "`") #TODO-PER: get the real syntax for this. We want to replace "single quote" with "backslash single quote"
  end
  
  def self.collect_item(user, uri, hit)
    # This collects an item for a particular user. Different users can collect the same item, but a single
    # user can only collect an item once. If the item was collected successfully, then this returns the
    # item. If there is an error, then it throws an exception.

    # Has it been collected before?
    cached_resource = CachedResource.find_by_uri(uri)
    if (cached_resource != nil)
      item = CollectedItem.find_by_user_id_and_cached_resource_id(user.id, cached_resource.id)
      if item != nil
        err_str = "Can't collect item because it is already collected. User=#{user.username} Item=#{uri}"
        logger.info(err_str)
        return  # Just return with no effect if it is already collected. It doesn't matter.
      end
    end
    
    # Create cached_resource item if it hasn't been created
    if (cached_resource == nil)
      cached_resource = CachedResource.new(:uri => uri)
			if hit == nil
				hit = CollexEngine.new().get_object(uri)
			end
			cached_resource.set_hit(hit)
    end
    
    # Store the item
    item = CollectedItem.new
    item.user = user
    item.cached_resource = cached_resource
    item.save!

		ObjectActivity.record_collect(user, uri)
    return item
  end
  
  def self.get(user, uri)
    cached_resource = CachedResource.find_by_uri(uri)
    if (cached_resource == nil)
      return nil
    end
    
    user_id = user.id
    cached_resource_id = cached_resource.id
    item = CollectedItem.find_by_user_id_and_cached_resource_id(user_id, cached_resource_id)
    return item
  end

  def self.remove_collected_item(user, uri)
    # Right now we've decided to never remove an item from the cache, even if it is no longer referenced, so we just
    # need to delete the reference. This may change if the cache grows stupendously.
    item = self.get(user, uri)
    if item == nil
      logger.info("Can't remove the item: #{user.username}, #{uri} because it couldn't be found")
      return  # Just return with no effect if it is already collected. It doesn't matter.
    end
     
    item.destroy()
		ObjectActivity.record_uncollect(user, uri)
  end
  
  def self.set_annotation(user, uri, note_str)
    username = user.username
    item = self.get(user, uri)
    if item == nil
      logger.info("Can't set the annotation because uri #{uri} is not collected by #{username}")
      return
    end
  
    item.update_attribute(:annotation, note_str)
  end
  
end
