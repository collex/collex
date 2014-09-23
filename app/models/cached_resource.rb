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
  #include PropertyMethods
  validates_uniqueness_of :uri
  after_create :copy_solr_resource
  
  has_many :tagassigns 
  has_many :tags, :through => :tagassigns 
  
  #has_and_belongs_to_many :tags
  has_many :cached_properties, :dependent => :destroy
  has_one :collected_item
  alias properties cached_properties

	def set_hit(hit)	# This saves a solr call if the object is already in our hands.
		@resource = hit
		# never collect full text
#		if @resource['text']
#			@resource['text'] = nil
#		end


	end

  # The actual +SolrResource+ at this instances +uri+. 
  def resource
    #@resource ||= SolrResource.find_by_uri(self.uri)
		return @resource if @resource != nil
		begin
		@resource = Catalog.factory_create(false).get_object(self.uri)
		rescue Catalog::Error => e
			@resource = nil
		end
		return @resource
  end
  #alias_method :solr_resource, :resource
  
  private
  @@site_thumbnails = {}

  def self.tag_cloud(user)
    sql_no_user = "select name, count(name) as freq from tags join tagassigns on tags.id=tagassigns.tag_id group by name order by name"
    sql_user = "select name, count(name) as freq from tags join tagassigns on tags.id=tagassigns.tag_id where user_id=? group by name order by name"
          
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
  
  # Add the resource at the specified URI to the cache
  #
  def self.add( uri, check_if_exists = true)
	  if check_if_exists
		  # just get it from the cache if it were already added.
		  hit = self.get_hit_from_uri(uri)
		  return hit if hit
		end

	  # The object isn't in the cache, so put it there
      cached_resource = CachedResource.new(:uri => uri)
      hit = Catalog.factory_create(false).get_object(uri)
      cached_resource.set_hit(hit)
      cached_resource.save!

	  if check_if_exists
		  # Retrieve it from the cache instead of returning it directly, because the cache may filter some fields.
		  # This way we know for sure that we will get the same results every time we call it.
		  hit = self.get_hit_from_uri(uri)
		  return hit
		end
  end
  
  # check if the specified URI exists as a cached resource
  #
  def self.exists(uri)
    return ( CachedResource.where(:uri => uri ).count > 0)
  end

	def self.get_most_popular_tags(num)
		cloud_info = CachedResource.get_tag_cloud_info(nil) # get all tags and their frequencies
		tags = cloud_info[:cloud_freq].sort {|a,b| b[1] <=> a[1]} # sort by frequency
		total_tags_wanted = tags.length > num ? num : tags.length
		total_bigger_tags = total_tags_wanted / 5
		tags = tags.slice(0, total_tags_wanted)  # we just want the top num tags.
		0.upto(total_bigger_tags-1) { |i| # now make a few of the tags larger
			tags[i][2] = true
		}
		total_bigger_tags.upto(total_tags_wanted-1) { |i| # now make a few of the tags larger
			tags[i][2] = false
		}
		tags = tags.sort {|a,b| a[0] <=> b[0]}  # now sort by tag name for display
		return tags
	end
	
	def self.get_most_recent_tags(num)
		sql_recent = "SELECT DISTINCT tags.name, count(tag_id) as freq FROM tagassigns join tags on tags.id = tagassigns.tag_id GROUP BY tag_id ORDER BY MAX(updated_at) DESC limit #{num}"
		cloud = find_by_sql([ sql_recent ]) 
		# convert active record objects to [name,freq] pairs
		if cloud != nil
			cloud = cloud.map { |entry| [ entry.name, entry.freq.to_i ] }
			freqs = cloud.sort {|a,b| b[1] <=> a[1] }
			return nil if freqs == nil || freqs.length == 0
			third = freqs[freqs.length*2/3][1]
			cloud = cloud.map {|tag|
				[ tag[0], tag[1], tag[1] > third ]
			}
		end
		return cloud
	end

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
      return { :cloud_freq => cloud_freq, :zoom_levels => {} }
    end
  
    # create a hash so we can see the frequency totals
    # the key is tag frequency, and the value is the number of tags with that frequency.
    freq_totals = {}
    cloud_freq.each do |item|
      tag_freq = item.last
      if freq_totals[tag_freq]
        freq_totals[tag_freq] = freq_totals[tag_freq] + 1
      else
        freq_totals[tag_freq] = 1
      end
    end # for each item in cloud_freq
    
    
    # order the freq_totals from lowest frequency to highest
    freq_totals = freq_totals.sort
    
    # there are 10 zoom levels. Each level has a set of 10 buckets
    # containing tags of increasing frequency (ie bucket 1 contains tags
    # that occur least frequenly and bucket 10 contains tags that occur most frequently
    zoom_levels = []
    for zoom_level in 1..10 do
       bucket_size = {}
       bucket = 1
       curr_zoom = 1
       
       # one entry in coud_freq for each unique tag, so total tags is length of array
       total_tags_left = cloud_freq.length   
       
       # even distrib of tags per bucket
       ideal_tags_per_bucket = total_tags_left / 10 
       num_in_this_bucket = 0
        
       freq_totals.each do |freq, tag_count|
         # throw away tags that are less than the current zoom level
         if curr_zoom < zoom_level
            num_in_this_bucket = num_in_this_bucket + tag_count
            total_tags_left = total_tags_left - tag_count
            if num_in_this_bucket > ideal_tags_per_bucket
               curr_zoom += 1
               num_in_this_bucket = 0
               ideal_tags_per_bucket = total_tags_left / (11 - bucket)
            end
         else
            # once curr zoom level is greater or equal to target zoom,
            # start throwing them into buckets
            bucket_size[freq] = bucket
            num_in_this_bucket = num_in_this_bucket + tag_count
            total_tags_left = total_tags_left - tag_count
            if num_in_this_bucket > ideal_tags_per_bucket && bucket < 10
              bucket += 1
              curr_zoom += 1
              num_in_this_bucket = 0
              ideal_tags_per_bucket = total_tags_left / (11 - bucket)
            end # if we're starting a new bucket
         end # if  frequency skipped
       end # for each item in the freq_totals hash
       
       # at the end of this loop, bucket_size hash is:
       # key: frequency, value: bucket number
       # So, it tells that tags of frequency(key) go into bucket(value)
       zoom_levels.push(bucket_size)
    end
    
    return { :cloud_freq => cloud_freq, :zoom_levels => zoom_levels }
    end
  
  def self.get_hit_from_uri(uri)
    return nil if uri == nil
    cr = CachedResource.find_by_uri(uri)
	if cr == nil
		self.add(uri, false)
		cr = CachedResource.find_by_uri(uri)
	end
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

	arch = hit['archive'].kind_of?(Array) ? hit['archive'][0] : hit['archive']
	if @@site_thumbnails.has_key?(arch)
		return @@site_thumbnails[arch]
	end

    site = Catalog.factory_create(false).get_archive(arch) #Site.find_by_code(hit['archive'])
    return nil if site == nil
    
    thumb = self.solr_obj_to_str(site['thumbnail'])
	  @@site_thumbnails[arch] = thumb
	  return thumb
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
    items = CollectedItem.all(:conditions => ["user_id = ?", user.id], :order => 'updated_at DESC', :limit => count )
    results = []
    items.each { |item|
      hit = get_hit_from_resource_id(item.cached_resource_id)
      results.insert(-1, hit) if hit != nil
    }
    return results
  end
 
  # Get all hits for a given tag. 
  # If a user is passed, then only the objects for that user are returned. Otherwise all matching objects are returned.
  #
  def self.get_hits_for_tag(tag_name, user)
    results = []
    tag = Tag.find_by_name(tag_name)
    # It's possible for this to return nil if a tag was deleted before this request was made.
    return results if tag == nil
    
    assigns = Tagassign.all(:conditions => [ "tag_id = ?", tag.id ] )
    assigns.each do | assign |
      if user == nil || assign.user_id == user.id
        hit = get_hit_from_resource_id(assign.cached_resource_id)
        results.insert(-1, hit) if hit != nil && !results.detect {|item| item['uri'] == hit['uri']}
      end
    end
    
    return results
  end
  
	# called in my_collex when viewing "all collected objects"
  def self.get_page_of_hits_by_user(user, page_num, items_per_page, sort_field, direction)
    items = CollectedItem.all(:conditions => ["user_id = ?", user.id], :order => 'updated_at DESC' )
		if sort_field
			items = items.map { |item|
				add_sort_field(item, sort_field)
			}
			items = sort_algorithm(items, sort_field)
			items = items.reverse() if direction == 'desc'
		end
    return self.get_page_of_results(items, page_num, items_per_page)
  end

  # Get a list of al of the items that have been tagged with the specified string
  #
  def self.get_page_of_hits_for_tag(tag_name, user, page_num, items_per_page, sort_field, direction)
    tag = Tag.find_by_name(tag_name)
    # It's possible for this to return nil if a tag was deleted before this request was made.
    return { :results => [], :total => 0 } if tag == nil
    
    # walk through all assignments that match this tag ID
	  retrieved_list = {}
    items = []
    assigns = Tagassign.where(:tag_id => tag.id).select(:cached_resource_id).map{|ta| ta.cached_resource_id}
    total = assigns.count

    if sort_field
      # get sorted list of cached resource ids
      assigns_sorted = Tagassign.joins(:cached_resource => :cached_properties).where('cached_properties.name' => sort_field, 'tagassigns.tag_id' => tag.id).select('tagassigns.cached_resource_id').order('cached_properties.value').map{|ta| ta.cached_resource_id}
      assigns = assigns_sorted + (assigns - assigns_sorted)
      assigns = assigns.reverse() if direction == 'desc'
    end

    assigns = assigns[(page_num*items_per_page)..(page_num*items_per_page+items_per_page-1)]
    assigns.each do | assign |
      if retrieved_list[assign].blank?
        hit = get_hit_from_resource_id( assign )
        retrieved_list[assign] = true
        items.insert(-1, hit) if hit != nil
      end
    end
		
		page_results = {}
		page_results[:results] = items
    page_results[:total] = total

    return page_results
  end
  
  def self.get_page_of_all_untagged(user, page_num, items_per_page, sort_field, direction)
	  # Find all collected items that don't have any tags for the particular user.
	  # User contains id
	  # CollectedItem contains user_id, cached_resource_id
	  # Tagassigns contains user_id, cached_resource_id
	  # We want to return all the CollectedItems that that don't have a corresponding Tagassigns
    return { :results => [], :total => 0 } if user == nil
    all_items = CollectedItem.where({user_id: user.id})
    items = []
    all_items.each { |item|
      first_tag = Tagassign.find_by_cached_resource_id_and_user_id(item.cached_resource_id, item.user_id)
      if !first_tag
				if sort_field
					item = add_sort_field(item, sort_field)
				end
        items.insert(-1, item)
      end
    }
		if sort_field
			items = sort_algorithm(items, sort_field)
			items = items.reverse() if direction == 'desc'
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
      hit = get_hit_from_resource_id(items[i][:cached_resource_id])
      results.insert(-1, hit) if hit != nil
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
			out_item = { id: item['id'], user_id: item['user_id'], cached_resource_id: item['cached_resource_id'], annotation: item['annotation'], created_at: item['created_at'], updated_at: item['updated_at'] }
			if sort_field == 'date_collected'
				out_item[sort_field] = item['updated_at']
				return out_item
			end

			cp = CachedProperty.first({:conditions => ["cached_resource_id = ? AND name = ?", item.cached_resource_id, sort_field]})

			out_item[sort_field] = cp ? cp.value : ''
			if sort_field == 'archive'
				site = Catalog.factory_create(false).get_archive(out_item[sort_field]) #Site.find_by_code(item[sort_field])
				if site
					out_item[sort_field] = site['name']
				end
			end
			out_item[sort_field] = out_item[sort_field].downcase().gsub(/\W/, '')
			return out_item
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

  def self.fill_hit(resource_id)
	  hit = {}
	  properties = CachedProperty.where({cached_resource_id: resource_id})
	  properties.each { |property|

		  hit[property.name] = [] if !hit[property.name]

		  if property.name != 'text' # make sure that full text never gets shown, even if it is mistakenly collected.
			  hit[property.name].insert(-1, property.value)
		  end
	  }
	return hit
  end
	public

	def self.get_hit_from_resource_id(resource_id)
		uri = CachedResource.find_by_id(resource_id)
		return nil if uri == nil
		hit = CachedResource.fill_hit(resource_id)
		if hit['title'].blank?
			# The object must have been improperly cached, so attempt to cache it again.
			uri.recache_properties()
			hit = CachedResource.fill_hit(resource_id)
		end
		hit['uri'] = uri.uri
		# some fields are not multivalued, so they shouldn't be arrays
		hit['archive'] = hit['archive'][0] if hit['archive'].present? && hit['archive'].kind_of?(Array)
		hit['freeculture'] = hit['freeculture'][0] if hit['freeculture'].present? && hit['freeculture'].kind_of?(Array)
		hit['image'] = hit['image'][0] if hit['image'].present? && hit['image'].kind_of?(Array)
		hit['thumbnail'] = hit['thumbnail'][0] if hit['thumbnail'].present? && hit['thumbnail'].kind_of?(Array)
		hit['title'] = hit['title'][0] if hit['title'].present? && hit['title'].kind_of?(Array)
		hit['url'] = hit['url'][0] if hit['url'].present? && hit['url'].kind_of?(Array)
		hit['has_full_text'] = hit['has_full_text'][0] if hit['has_full_text'].present? && hit['has_full_text'].kind_of?(Array)
		hit['is_ocr'] = hit['is_ocr'][0] if hit['is_ocr'].present? && hit['is_ocr'].kind_of?(Array)
		hit['typewright'] = hit['typewright'][0] if hit['typewright'].present? && hit['typewright'].kind_of?(Array)
		return hit
  end

  def self.get_hit_from_cached_resource(cr)
    hit = {}
    return nil if cr.nil?
    cr.cached_properties.each { |property|
      hit[property.name] = [] if !hit[property.name]
      if property.name != 'text' # make sure that full text never gets shown, even if it is mistakenly collected.
        hit[property.name].insert(-1, property.value)
      end
    }
    hit['uri'] = cr.uri
    # some fields are not multivalued, so they shouldn't be arrays
    hit['archive'] = hit['archive'][0] if hit['archive']
    hit['freeculture'] = hit['freeculture'][0] if hit['freeculture']
    hit['image'] = hit['image'][0] if hit['image']
    hit['thumbnail'] = hit['thumbnail'][0] if hit['thumbnail']
    hit['title'] = hit['title'][0] if hit['title']
    hit['url'] = hit['url'][0] if hit['url']
    hit['has_full_text'] = hit['has_full_text'][0] if hit['has_full_text']
    hit['is_ocr'] = hit['is_ocr'][0] if hit['is_ocr']
    hit['typewright'] = hit['typewright'][0] if hit['typewright']
    return hit
  end

end
