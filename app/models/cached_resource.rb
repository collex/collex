##########################################################################
# Copyright 2008 Applied Research in Patacriticism and the University of Virginia
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

class CachedResource < ActiveRecord::Base
  include PropertyMethods
  validates_uniqueness_of :uri
  after_create :copy_solr_resource
  
  has_and_belongs_to_many :tags
  has_many :cached_properties, :dependent => :destroy
  has_one :collected_items
  alias properties cached_properties

	def set_hit(hit)	# This saves a solr call if the object is already in our hands.
		@resource = hit
	end

  # The actual +SolrResource+ at this instances +uri+. 
  def resource
    #@resource ||= SolrResource.find_by_uri(self.uri)
		return @resource if @resource != nil
		@resource = CollexEngine.new.get_object(self.uri)
		return @resource
  end
  #alias_method :solr_resource, :resource
  
  private
  def self.tag_cloud(user)
    sql_no_user = "select name, count(name) as freq from tags join tagassigns on tags.id=tagassigns.tag_id group by name order by name"
    sql_user = "select name, count(name) as freq from tags join tagassigns on tags.id=tagassigns.tag_id join collected_items as i on tagassigns.collected_item_id=i.id where user_id=? group by name order by name"
          
    cloud_of_ar_objects = if user.nil? 
      find_by_sql([ sql_no_user ]) 
    else
      find_by_sql([ sql_user, user ])
    end      
         
    # convert active record objects to [name,freq] pairs
    unless cloud_of_ar_objects.nil?  
      return cloud_of_ar_objects.map { |entry| [ entry.name, entry.freq.to_i ] }
    else
      return []
    end
  end
  public
  
  def self.get_tag_cloud_info(user)
    # This gets all the tags, the number of times they've been used, and their relative sizes in the cloud.
    # The return value is a list of all tag names and their frequency, also a hash of all frequencies and their bucket size.

    # The relative sizes of the tags should be distributed as equally as possible.
    # The problem is that the number of times they've been used is not distributed equally. The lower numbers
    # tend to occur much more frequently than the higher numbers, so if a pure mean were used, then most of the
    # tags would be the smallest size and the last few sizes would tend to have the same number of items in it.
    # Therefore, the following algorithm is used to try to distribute the sizes.
    
    # First, we create a hash with the key being the number of times a tag has occurred and the value being the number of tags
    # that occur that many times. That is, the hash { 5 => 2 } means that there are two tags, each of which occurs five times.
    # If there are less than 10 items in the hash, then we just distribute the tags from the smallest size and we're done.

    # Otherwise, we have to figure out which frequencies go in each bucket.
    # We fill the buckets up from smallest to largest. The first bucket starts with the least frequent tags (probably the ones occurring only once).
    # We take the total number of tags / 10 to get the average number of tags we'd like in each bucket. If the first bucket has less than that number
    # of tags, then we also fill it with the next batch of tags, etc, until we've put "total / 10" tags in the bucket.
    # Now, because of our distribution, we've probably put many more tags in that bucket than we'd like, so instead of filling the rest of the buckets
    # equally, we subtract the number of tags we've used from the total, then divide that number by 9 to get the ideal number of tags for the next bucket.
    
    cloud_freq = self.tag_cloud(user) # cloud_freq is an array of arrays, with the inner array containing 0=tag_name, 1=frequency

    if cloud_freq.empty?
      return { :cloud_freq => cloud_freq, :bucket_size => {} }
    end
  
    # create a hash of buckets so we can see each frequency.
    # the key is a frequency, and the value is the number of tags with that frequency.
    buckets = {}
    cloud_freq.each do |item|
      size = item.last
      if buckets[size]
        buckets[size] = buckets[size] + 1
      else
        buckets[size] = 1
      end
    end # for each item in cloud_freq
    buckets = buckets.sort
    
    bucket_size = {}
    bucket = 1
    total_tags_left = cloud_freq.length
    ideal_tags_per_bucket = total_tags_left / (11 - bucket)
    num_in_this_bucket = 0
    buckets.each do |key,value|
      bucket_size[key] = bucket
      num_in_this_bucket = num_in_this_bucket + value
      total_tags_left = total_tags_left - value
      if num_in_this_bucket > ideal_tags_per_bucket && bucket < 10
        bucket += 1
        num_in_this_bucket = 0
        ideal_tags_per_bucket = total_tags_left / (11 - bucket)
      end # if we're starting a new bucket
    end # for each item in the bucket hash

    return { :cloud_freq => cloud_freq, :bucket_size => bucket_size }
    end
  
  def self.get_hit_from_uri(uri)
    return nil if uri == nil
    cr = CachedResource.find_by_uri(uri)
    return nil if cr == nil
    return get_hit_from_resource_id(cr.id)
  end
  
  def self.get_image_from_uri(uri)
    return nil if uri == nil
    hit = CachedResource.get_hit_from_uri(uri)
  	return nil unless hit
    return self.get_image_from_hit(hit)
  end
  
  def self.get_image_from_hit(hit)
    return nil if hit == nil
    image = self.solr_obj_to_str(hit['image'])
    if image == nil
      image = self.get_thumbnail_from_hit(hit)
    end
    return image
  end
  
  def self.get_thumbnail_from_uri(uri)
    return nil if uri == nil
   hit = CachedResource.get_hit_from_uri(uri)
    return nil unless hit
    return self.get_thumbnail_from_hit(hit)
  end
  
  def self.get_thumbnail_from_hit(hit)
    return nil if hit == nil
    image =  self.solr_obj_to_str(hit['thumbnail'])
    return image if image != nil

    site = Site.find_by_code(hit['archive'])
    return nil if site == nil
    
    return self.solr_obj_to_str(site.thumbnail)
  end
  
  def self.get_thumbnail_from_hit_no_site(hit)
    return nil if hit == nil
    image =  self.solr_obj_to_str(hit['thumbnail'])
    return image
  end
  
  def self.get_link_from_uri(uri)
    return nil if uri == nil
    hit = CachedResource.get_hit_from_uri(uri)
    return nil unless hit
    return self.get_link_from_hit(hit)
  end
  
  def self.get_link_from_hit(hit)
    return nil if hit == nil
    return self.solr_obj_to_str(hit['url'])
  end
    
  private
  def self.solr_obj_to_str(obj)
    if obj.kind_of?(Array) && obj.length > 0
      return obj[0]
    elsif obj.kind_of?(String)
      return obj
    else
      nil
    end
  end
  public

  def self.get_newest_collections(user, count) # Pass in the actual user object (not just the user name), and get back an array of results. Each result is a hash of all the properties that were cached.
    items = CollectedItem.find(:all, :conditions => ["user_id = ?", user.id], :order => 'updated_at DESC', :limit => count )
    results = []
    items.each { |item|
      hit = get_hit_from_resource_id(item.cached_resource_id)
      results.insert(-1, hit)
    }
    return results
  end
   
  # if a user is passed, then only the objects for that user are returned. Otherwise all matching objects are returned.
  def self.get_hits_for_tag(tag_name, user)
    results = []
    tag = Tag.find_by_name(tag_name)
    # It's possible for this to return nil if a tag was deleted before this request was made.
    return results if tag == nil
    
    item_ids = Tagassign.find(:all, :conditions => [ "tag_id = ?", tag.id ] )
    # item_ids are ids into the collected_items table.
    item_ids.each { |item_id|
      coll_item = CollectedItem.find_by_id(item_id.collected_item_id)
      if coll_item != nil && (user == nil || coll_item.user_id == user.id)
        hit = get_hit_from_resource_id(coll_item.cached_resource_id)
        results.insert(-1, hit) if !results.detect {|item| item['uri'] == hit['uri']} 
      end
    }
    return results
  end
  
	# called in my9s when viewing "all collected objects"
  def self.get_page_of_hits_by_user(user, page_num, items_per_page, sort_field, direction)
    items = CollectedItem.find(:all, :conditions => ["user_id = ?", user.id], :order => 'updated_at DESC' )
		if sort_field
			items.each { |item|
				item = add_sort_field(item, sort_field)
			}
			items = sort_algorithm(items, sort_field)
			items = items.reverse() if direction == 'Descending'
		end
    return self.get_page_of_results(items, page_num, items_per_page)
  end

  def self.get_page_of_hits_for_tag(tag_name, user, page_num, items_per_page, sort_field, direction)
    tag = Tag.find_by_name(tag_name)
    # It's possible for this to return nil if a tag was deleted before this request was made.
    return { :results => [], :total => 0 } if tag == nil
    
    items = []
    item_ids = Tagassign.find(:all, :conditions => [ "tag_id = ?", tag.id ] )
    # item_ids are ids into the collected_items table.
    item_ids.each { |item_id|
      coll_item = CollectedItem.find_by_id(item_id.collected_item_id)
      if coll_item != nil && (user == nil || coll_item.user_id == user.id)
				if !items.detect {|item| item.cached_resource_id == coll_item.cached_resource_id}
					if sort_field
						coll_item = add_sort_field(coll_item, sort_field)
					end
	        items.insert(-1, coll_item)
				end
      end
    }
		if sort_field
			items = sort_algorithm(items, sort_field)
			items = items.reverse() if direction == 'Descending'
		end
    return self.get_page_of_results(items, page_num, items_per_page)
  end
  
  def self.get_page_of_all_untagged(user, page_num, items_per_page, sort_field, direction)
    return { :results => [], :total => 0 } if user == nil
    all_items = CollectedItem.find(:all, :conditions => ["user_id = ?", user.id], :order => 'updated_at DESC'  )
    items = []
    all_items.each { |item|
      first_tag = Tagassign.find(:first, :conditions => ["collected_item_id = ?", item.id])
      if !first_tag
				if sort_field
					item = add_sort_field(item, sort_field)
				end
        items.insert(-1, item)
      end
    }
		if sort_field
			items = sort_algorithm(items, sort_field)
			items = items.reverse() if direction == 'Descending'
		end
    return self.get_page_of_results(items, page_num, items_per_page)
  end
  
	  def recache_properties
    if !resource.nil?
      CachedProperty.delete_all( ["cached_resource_id = ?", id] )
      copy_solr_resource
      logger.info("#{id}. Recaching: #{uri}")
      
      begin
        save!
      rescue ActiveRecord::RecordInvalid => e
        # This can fail if a duplicate URI gets in the database for whatever reason. Don't worry about that
        logger.info("-- Duplicate record")
      end
    else
      # The resource no longer exists. Add a property to tell us that. (Note that the current set of properties are not deleted, either)
      CachedProperty.create(:name => 'stale', :value => 'yes', :cached_resource_id => id)
      logger.info("Cached Resource \"#{uri}\" no longer exists in solr.")
    end
  end
  
  private
  def self.get_page_of_results(items, page_num, items_per_page)
    # items can either be an array of CollectedItem or resource_id
    first = page_num*items_per_page
    last = first + items_per_page - 1
    last = items.length - 1 if last > items.length - 1
    
    results = []
    first.upto(last) { |i|
      hit = get_hit_from_resource_id(items[i].cached_resource_id)
      results.insert(-1, hit)
    }
    return { :results => results, :total => items.length }
  end
  
    #TODO filter out tags and annotations and usernames 
    def copy_solr_resource
      return if resource.nil?
      resource.each do |name, val|
				if name != 'uri'
					if val.kind_of?(Array)
						val.each { |v|
							properties << CachedProperty.new(:name => name, :value => v)
						}
					else
						properties << CachedProperty.new(:name => name, :value => val)
					end
				end
      end
#      resource.properties.each do |prop|
#        properties << CachedProperty.new(:name => prop.name, :value => prop.value)
#      end
    end

		def self.add_sort_field(item, sort_field)
			if sort_field == 'date_collected'
				item[sort_field] = item['updated_at']
				return item
			end

			cp = CachedProperty.first({:conditions => ["cached_resource_id = ? AND name = ?", item.cached_resource_id, sort_field]})

			item[sort_field] = cp ? cp.value : ''
			if sort_field == 'archive'
				site = Site.find_by_code(item[sort_field])
				if site
					item[sort_field] = site['description']
				end
			end
			item[sort_field] = item[sort_field].downcase().gsub(/\W/, '')
			return item
		end

	def self.field_has_value(field)
		return false if field == nil
		if field.class == 'String'
			return field.length > 0
		end
		return true
	end

	def self.sort_algorithm(results, field)
			results = results.sort { |a,b|
				if field_has_value(a[field]) && field_has_value(b[field])
					a[field] <=> b[field]
				elsif field_has_value(a[field])
					1 <=> 2
				else
					2 <=> 1
				end
			}
			return results
	end
	public

  def self.get_hit_from_resource_id(resource_id)
    hit = {}
    uri = CachedResource.find(resource_id)
    properties = CachedProperty.find(:all, {:conditions => ["cached_resource_id = ?", resource_id]})
    properties.each do |property|
      if !hit[property.name]
        hit[property.name] = []
      end
      if property.name == 'title'
        bytes = ""
        #property.value.each_byte { |c| bytes += "#{c} " if c > 127 }
        hit[property.name].insert(-1, property.value + bytes)
      else
        hit[property.name].insert(-1, property.value)
      end
    end
    hit['uri'] = uri.uri
    return hit
  end

  # This takes either a UTF-8 encoded string or an ISO-8859-1 encoded string and
  # outputs a UTF-8 encoded string.
  def self.fix_char_set(str)
    begin
      arr = str.unpack('U*')  # This will fail if it is not a UTF-8 encoded string
    rescue
      arr = str.unpack('C*')  # Therefore it was an ISO-8859-1 encoded string
    end
    return arr.pack('U*') # Turn it back into a string
  end
  
end
