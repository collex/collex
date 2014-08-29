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

	def self.items_in_uri_list(user_id, uris)
		sql_left = "select uri,updated_at,annotation from collected_items inner join cached_resources on collected_items.`cached_resource_id` = cached_resources.id where user_id = #{user_id} AND cached_resources.uri in ("
		sql_right = ");"
		uris = uris.map { |uri| "'" + uri.gsub("\'") { |apos| "\\\'" } + "'" }
		collected_items = ActiveRecord::Base.connection.execute(sql_left + uris.join(',')+sql_right)
		list = {}
		collected_items.each { |item|
			list[item[0]] = { updated_at: item[1], annotation: item[2] }
		}
		return list
	end

  def self.get_all_users_collections(user)
    return CollectedItem.where({user_id: user.id})
  end

  # This returns the collected objects as a json string
  def self.get_collected_object_array(user_id)
    objs = CollectedItem.where({user_id: user_id})
    str = ""
    objs.each {|obj|
      hit = CachedResource.get_hit_from_resource_id(obj.cached_resource_id)
      if hit != nil
        image = CachedResource.get_thumbnail_from_hit(hit)
        image = ActionController::Base.new.view_context.image_path(DEFAULT_THUMBNAIL_IMAGE_PATH) if image == "" || image == nil
        if str != ""
          str += ",\n"
        end
        str += "{ uri: '#{hit['uri']}', thumbnail: '#{image}', title: '#{self.escape_quote(hit['title'])}'}"
      end
    }
    
    return '[' + str + ']'
  end

	def self.get_collected_objects_for_thumbnails(user_id, exhibit_id, is_chosen)
		# This was really slow going through ActiveRecord, so here's a quicker query.
#		if is_chosen == 'true'
#			sql = "select cached_resources.id,cached_resources.uri,cached_properties.name,cached_properties.value from collected_items inner join cached_resources on cached_resources.id = collected_items.cached_resource_id inner join cached_properties on cached_properties.cached_resource_id = collected_items.cached_resource_id inner join exhibit_objects on exhibit_objects.uri = cached_resources.uri where collected_items.user_id = #{user_id} and (cached_properties.name = 'archive' || cached_properties.name = 'title' || cached_properties.name = 'role_AUT' || cached_properties.name = 'role_ART') and exhibit_objects.exhibit_id = #{exhibit_id}"
#		else
#			sql = "select cached_resources.id,cached_resources.uri,cached_properties.name,cached_properties.value from collected_items inner join cached_resources on cached_resources.id = collected_items.cached_resource_id inner join cached_properties on cached_properties.cached_resource_id = collected_items.cached_resource_id left outer join exhibit_objects on exhibit_objects.uri = cached_resources.uri where collected_items.user_id = #{user_id} and (cached_properties.name = 'archive' || cached_properties.name = 'title' || cached_properties.name = 'role_AUT' || cached_properties.name = 'role_ART') and (exhibit_objects.exhibit_id is null or exhibit_objects.exhibit_id <> #{exhibit_id})"
#		end

		# first we have to get the chosen items, then if we want the unchosen ones, we need to get all of the items and remove the chosen ones.
		# That is because an item might be in two exhibits, so would match both sides.
		sql = "select cached_resources.id,cached_resources.uri,cached_properties.name,cached_properties.value from collected_items inner join cached_resources on cached_resources.id = collected_items.cached_resource_id inner join cached_properties on cached_properties.cached_resource_id = collected_items.cached_resource_id inner join exhibit_objects on exhibit_objects.uri = cached_resources.uri where collected_items.user_id = #{user_id} and (cached_properties.name = 'archive' || cached_properties.name = 'title' || cached_properties.name = 'role_AUT' || cached_properties.name = 'thumbnail' || cached_properties.name = 'role_ART') and exhibit_objects.exhibit_id = #{exhibit_id}"

		recs = {}
		match = ActiveRecord::Base.connection.execute(sql)
		match.each { |rec|
			if recs[rec[1]] == nil
				recs[rec[1]] = { 'uri' => rec[1], 'exhibit_id' => rec[0] }
			end
			if recs[rec[1]][rec[2]]
				recs[rec[1]][rec[2]] += ", #{rec[3]}" if recs[rec[1]][rec[2]].include?(rec[3]) == nil
			else
				recs[rec[1]][rec[2]] = rec[3]
			end
		}

		# now recs contains all the items that have been chosen
		return recs if is_chosen == 'true'
		chosen = recs

		#sql = "select exhibit_objects.exhibit_id,cached_resources.uri,cached_properties.name,cached_properties.value from collected_items inner join cached_resources on cached_resources.id = collected_items.cached_resource_id inner join cached_properties on cached_properties.cached_resource_id = collected_items.cached_resource_id inner join exhibit_objects on exhibit_objects.uri = cached_resources.uri where collected_items.user_id = #{user_id} and (cached_properties.name = 'archive' || cached_properties.name = 'title' || cached_properties.name = 'role_AUT' || cached_properties.name = 'thumbnail' || cached_properties.name = 'role_ART')"
		sql = "select cached_resources.id,cached_resources.uri,cached_properties.name,cached_properties.value from collected_items inner join cached_resources on cached_resources.id = collected_items.cached_resource_id inner join cached_properties on cached_properties.cached_resource_id = collected_items.cached_resource_id where collected_items.user_id = #{user_id}"
		recs = {}
		match = ActiveRecord::Base.connection.execute(sql)
		match.each { |rec|
			if recs[rec[1]] == nil
				recs[rec[1]] = { 'uri' => rec[1] }
			end
			if recs[rec[1]][rec[2]]
				recs[rec[1]][rec[2]] += ", #{rec[3]}" if recs[rec[1]][rec[2]].include?(rec[3]) == nil
			else
				recs[rec[1]][rec[2]] = rec[3]
			end
		}

		recs.delete_if {|key,hit|
			chosen.has_key?(key)
		}
		return recs
	end

	def self.get_collected_objects(user_id)
#		sql1 = "select uri,archive,title,author,thumbnail FROM "
#		sql2 = "(select exhibit_objects.id AS exhibit_objects_id,cached_resources.id AS cached_resources_id,cached_resources.uri, "
#		sql3 = "CASE WHEN cp1.name = 'archive' THEN cp1.value END AS archive, "
#		sql4 = "CASE WHEN cp1.name = 'title' THEN cp1.value END AS title, "
#		sql5 = "CASE WHEN cp1.name = 'role_AUT' or cp1.name = 'role_ART' THEN cp1.value END AS author, "
#		sql6 = "CASE WHEN cp1.name = 'thumbnail' THEN cp1.value END AS thumbnail "
#		sql7 = "from collected_items "
#		sql8 = "inner join cached_resources on cached_resources.id = collected_items.cached_resource_id "
#		sql9 = "inner join cached_properties AS cp1 on cp1.cached_resource_id = collected_items.cached_resource_id "
#		sql10 = "left outer join exhibit_objects on exhibit_objects.uri = cached_resources.uri "
#		sql11 = "where collected_items.user_id = #{user_id} and (cp1.name = 'archive' || cp1.name = 'title' || cp1.name = 'role_AUT' || cp1.name = 'role_ART' || cp1.name = 'thumbnail') ) as tbl1"
#		sql = "#{sql1}#{sql2}#{sql3}#{sql4}#{sql5}#{sql6}#{sql7}#{sql8}#{sql9}#{sql10}#{sql11}"

	  statement = [ "select cached_resources.id,cached_resources.uri,cached_properties.name,cached_properties.value from collected_items",
		"inner join cached_resources on cached_resources.id = collected_items.cached_resource_id",
		"inner join cached_properties on cached_properties.cached_resource_id = collected_items.cached_resource_id",
#TODO-PER: don't know why this was ever here:		"inner join exhibit_objects on exhibit_objects.uri = cached_resources.uri",
		"where collected_items.user_id = #{user_id}",
		"and (cached_properties.name = 'archive' || cached_properties.name = 'title' || cached_properties.name = 'role_AUT' || cached_properties.name = 'role_ART' || cached_properties.name = 'thumbnail' || cached_properties.name = 'archive')"
		]
		sql = statement.join(' ')

		recs = {}
		match = ActiveRecord::Base.connection.execute(sql)
		match.each { |rec|
#			if recs[rec[0]] == nil
#				recs[rec[0]] = { 'uri' => rec[0] }
#			end
#			recs[rec[0]]['archive'] = rec[1] if rec[1]
#			recs[rec[0]]['title'] = rec[2] if rec[2]
#			recs[rec[0]]['author'] = rec[3] if rec[3]
#			recs[rec[0]]['thumbnail'] = rec[4] if rec[4]
			if recs[rec[1]] == nil
				recs[rec[1]] = { 'uri' => rec[1] }
			end
			if recs[rec[1]][rec[2]]
				recs[rec[1]][rec[2]] += ", #{rec[3]}" if !recs[rec[1]][rec[2]].include?(rec[3])
			else
				recs[rec[1]][rec[2]] = rec[3]
			end
		}
		return recs

	end

  # this returns the collected objects as a ruby array
  def self.get_collected_object_ruby_array(user_id)
    objs = CollectedItem.where({user_id: user_id})
    arr = []
    objs.each {|obj|
      hit = CachedResource.get_hit_from_resource_id(obj.cached_resource_id)
      if hit != nil
        image = CachedResource.get_thumbnail_from_hit(hit)
        image = ActionController::Base.new.view_context.image_path(DEFAULT_THUMBNAIL_IMAGE_PATH) if image == "" || image == nil
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
				hit = Catalog.factory_create(false).get_object(uri)
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
