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

class Tag < ActiveRecord::Base
  has_many :tagassigns 
  has_many :cached_resources, :through => :tagassigns 

  validates_uniqueness_of :name

	def self.items_in_uri_list(uris,curr_user_id)
		sql_left = "select uri,name,user_id from tagassigns inner join cached_resources on tagassigns.`cached_resource_id` = cached_resources.id inner join tags on tagassigns.tag_id = tags.id where cached_resources.uri in ("
		sql_right = ");"
		uris = uris.map { |uri| "'" + uri.gsub("\'") { |apos| "\\\'" } + "'" }
		tags = ActiveRecord::Base.connection.execute(sql_left + uris.join(',')+sql_right)
		list = {}
		other_list = {}
		tags.each { |item|
			if item[2] == curr_user_id
				if list[item[0]].nil?
					list[item[0]] = [ item[1] ]
				else
					list[item[0]].push(item[1])
				end
			else
				if other_list[item[0]].nil?
					other_list[item[0]] = [ item[1] ]
				else
					other_list[item[0]].push(item[1])
				end
			end
		}
		return list,other_list

	end

  # Add a new tag to an item. Collected/Uncollected is irrelevant; tags are associated 
  # directly with the cached resource id. If the item is not yet cached, it will be.
  #
  def self.add(user, uri, tag_info)
    
    # See if the resource has been cached - cache it if not
    cached_resource = CachedResource.find_by_uri(uri)
    if cached_resource.nil?
      CachedResource.add( uri )
      cached_resource = CachedResource.find_by_uri(uri)
    end

    # find or create the tag record.
    tag_info['name'].split(",").each do | tag |
       tag = tag.strip
       tag = self.normalize_tag_name(tag)
       tag_rec = Tag.find_by_name(tag)
       if tag_rec == nil
         tag_rec = Tag.new(:name => tag)
         tag_rec.save!
       end
   
       # see if this item has already been tagged
       tagassign = Tagassign.find_by_tag_id_and_cached_resource_id(tag_rec.id, cached_resource.id)
       
       # create a new tag assign for this type of tag
       if tagassign.nil?
         tagassign = Tagassign.new(:tag_id => tag_rec.id, :user_id => user.id, :cached_resource_id => cached_resource.id) 
         tagassign.save!
       else
         tagassign.update_attribute(:updated_at, Time.now)
       end
   
       ObjectActivity.record_tag(user, uri, tag)
    end
  end
  
  # Get a list of tags associated with the specified URI. This list is an
  # array of arrays. Format: [tagname][ usser_id] 
  #
  def self.get_tags_for_uri(uri)
    
    # find the cached item. If it isn't cached, we know there aren't any tags for it.
    cached_resource = CachedResource.find_by_uri(uri)
    if (cached_resource == nil)
      return []
    end

    tags = {}

    # find any times this was tagged when not collected
    assignments = Tagassign.where({cached_resource_id: cached_resource.id})
    assignments.each do | assignment |
      tag = Tag.find(assignment.tag_id)
      if tags.has_key?(tag) == false
        tags[tag.name] = { user: assignment.user_id, tag: tag.id }
      end
    end
    
    # clear out duplicates and sort. This will return a sorted array of arrays.
    # secondary array is [tagname][owner]
    return tags.sort
  end
  
  # Delete specified tag
  #
  def self.remove(user, uri, tag_id)

    # Grab the resource associated with the URI
    cached_resource = CachedResource.find_by_uri(uri)
    if cached_resource.nil?
      logger.info("Can't delete the tag because uri #{uri} is not cached")
    end

    # find the tag record. We might have been passed either an id or the tag name.
    tag_rec = Tag.find_by_id(tag_id)
	tag_rec = Tag.find_by_name(tag_id) if tag_rec.nil?
    if tag_rec.nil?
      # For some reason the tag was already deleted. Don't worry about it, 
      # it was probably a race condition or stale session.
      return
    end

    # do the delete
    tagassign = Tagassign.find_by_user_id_and_tag_id_and_cached_resource_id( user.id, tag_rec.id, cached_resource.id )
    if tagassign == nil
      logger.info("Can't delete the tag because the tag #{tag_rec.name} was not assigned to the uri #{uri} by user #{user.username}")
      return
    else
      
      # kill the assignment
      tagassign.destroy
      
      # if there are no assignments for the tag, remove it too
      resources = tag_rec.cached_resources
      tag_rec.destroy if resources.length == 0 
      
      ObjectActivity.record_untag(user, uri, tag_rec.name)
    end     

  end
  
  # Rename a tag from old_tag_str to new_tag_str. If these string are equal 
  # or the new string is empty, do nothing
  #  
  def self.rename(user, uri, old_tag_str, new_tag_str)
    
    # cleanup both names
    old_tag_str = self.normalize_tag_name(old_tag_str)
    new_tag_str = self.normalize_tag_name(new_tag_str)
    
    # if the tag name hasn't changed, then we have nothing to do
    return if old_tag_str == new_tag_str  || new_tag_str.length== 0 

    self.add(user, uri, {'name' => new_tag_str})
    self.remove(user, uri, old_tag_str)
  end
  
  # clean up tag name
  #
  def self.normalize_tag_name(tag)
    tag = tag.strip()
    tag = tag.downcase()
    tag = tag.gsub(' ', '_')
    tag = tag.gsub('.', '_')
    tag = tag.gsub('?', '_')
    return tag.gsub('/', '_')
  end
  
end
