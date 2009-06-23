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
  
  # The actual +SolrResource+ at this instances +uri+. 
  def resource
    @resource ||= SolrResource.find_by_uri(self.uri)
  end
  alias_method :solr_resource, :resource
  
#  CLOUD_SQL = { 
#    :archive => "select value as name, count(value) as freq from cached_properties as props join cached_resources as docs on docs.id=props.cached_resource_id where props.name = 'archive'  group by value order by value limit ?",
#    :agent_facet => "select value as name, count(value) as freq from cached_properties as agents join cached_resources as docs on docs.id=agents.cached_resource_id  where agents.name like 'role_%' group by value order by value limit ?", 
#    :tag => "select name, count(name) as freq from tags join tagassigns on tags.id=tagassigns.tag_id group by name order by name limit ?",
#    :genre => "select value as name, count(value) as freq from cached_properties as genres join cached_resources as docs on docs.id=genres.cached_resource_id where genres.name = 'genre'  group by value order by name limit ?",     
#    :username => "select username as name, count(username) as freq from users join interpretations as i on users.id=i.user_id group by username order by name limit ?",
#    :year => "select value as name, count(value) as freq from cached_properties as dates join cached_resources as docs on dates.cached_resource_id=docs.id where dates.name = 'date_label' group by dates.value order by value limit ?"
#  }
#  
#  CLOUD_BY_USER_SQL = { 
#    :archive => "select value as name, count(value) as freq from cached_properties as props join cached_resources as docs on docs.id=props.cached_resource_id join interpretations as i on docs.uri=i.object_uri  where user_id=? and props.name = 'archive' group by value order by value limit ?",
#    :agent_facet => "select value as name, count(value) as freq from cached_properties as agents join cached_resources as docs on docs.id=agents.cached_resource_id join interpretations as i on docs.uri=i.object_uri where user_id=? and agents.name like 'role_%' group by value order by value limit ?", 
#    :tag => "select name, count(name) as freq from tags join tagassigns on tags.id=tagassigns.tag_id join collected_items as i on tagassigns.collected_item_id=i.id where user_id=? group by name order by name limit ?",
#    :genre => "select value as name, count(value) as freq from cached_properties as genres join cached_resources as docs on docs.id=genres.cached_resource_id join interpretations as i on docs.uri=i.object_uri  where user_id=? and genres.name = 'genre' group by value order by value limit ?",
#    :username => "select username as name, count(username) as freq from users join interpretations as i on users.id=i.user_id where users.id = ? group by username order by name limit ?",
#    :year => "select value as name, count(value) as freq from cached_properties as dates join cached_resources as docs on dates.cached_resource_id=docs.id join interpretations as i on docs.uri=i.object_uri where user_id=? and dates.name = 'date_label' group by dates.value order by value limit ?",
#    :all_tags => "select name, count(name) as freq from tags join taggings on tags.id=taggings.tag_id join interpretations as i on taggings.interpretation_id=i.id where user_id=? group by name order by name"
#  }
  
#  LIST_SQL_SELECT = "select docs.* from cached_resources as docs"
#  LIST_SQL_COUNT = "select count(*) as hits from cached_resources as docs"
#  LIST_SQL_ORDER_AND_LIMIT = " limit ?,?"
#  
#  LIST_BY_TAG_SQL = {
#    :archive => "join cached_properties props on docs.id = props.cached_resource_id where name='archive' and value=?",
#    :agent_facet => "join cached_properties as props on docs.id=props.cached_resource_id where props.name like 'role_%' and props.value = ?", 
#    :tag => "join cached_resources_tags as doc_tags on docs.id=doc_tags.cached_resource_id join tags on doc_tags.tag_id=tags.id where tags.name=?", 
#    :genre => "join cached_properties as props on docs.id=props.cached_resource_id where props.name = 'genre' and props.value = ?",
#    :username => "join interpretations as i on docs.uri=i.object_uri join users on i.user_id=users.id where i.user_id.username=?",
#    :year => "join cached_properties as props on docs.id=props.cached_resource_id where props.name = 'date_label' and props.value = ?"
#  }
#
#  LIST_BY_USER_BY_TAG_SQL = {
#    :archive => "join cached_properties props on docs.id = props.cached_resource_id 
#                 join interpretations as i on docs.uri=i.object_uri 
#                 where name='archive' and value=? and i.user_id = ?",
#    :agent_facet => "join interpretations as i on docs.uri=i.object_uri 
#                     join cached_properties as props on docs.id=props.cached_resource_id 
#                     where props.name like 'role_%' and props.value = ? and i.user_id = ?", 
#    :tag => "join interpretations as i on docs.uri=i.object_uri 
#             join cached_resources_tags as doc_tags on docs.id=doc_tags.cached_resource_id 
#             join tags on doc_tags.tag_id=tags.id 
#             where tags.name=? and i.user_id = ?", 
#    :genre => "join interpretations as i on docs.uri=i.object_uri 
#               join cached_properties as props on docs.id=props.cached_resource_id 
#               where props.name = 'genre' and props.value = ? and i.user_id = ?",   
#    :username => "join interpretations as i on docs.uri=i.object_uri 
#                  join users on i.user_id=users.id where users.username=? and i.user_id = ?",
#    :year => "join interpretations as i on docs.uri=i.object_uri 
#              join cached_properties as props on docs.id=props.cached_resource_id 
#              where props.name = 'date_label' and props.value = ? and i.user_id = ?"
#  }

#  DOCUMENT_LIMIT = 1000
  
  # Returns a sorted array of [name,freq] pairs for the specified cloud type and optional user_id
  # TODO-PER: This is probably obsolete and can go away.
#  def self.cloud( type, user=nil, limit=nil )
#    type = type.to_sym
#    limit = limit.nil? ? DOCUMENT_LIMIT : limit.to_i
#          
#    cloud_of_ar_objects = if user.nil? 
#      find_by_sql([ CLOUD_SQL[type], limit ]) 
#    else
#      find_by_sql([ CLOUD_BY_USER_SQL[type], user, limit ])
#    end      
#         
#    # convert active record objects to [name,freq] pairs
#    unless cloud_of_ar_objects.nil?  
#      return cloud_of_ar_objects.map { |entry| [ entry.name, entry.freq.to_i ] }
#    else
#      return []
#    end
#  end
  
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
  
  # Returns a sorted array of CachedResource objects associated with a given cloud tag and optionally restricts by user
  # TODO-PER: This is only called from the sidebar, so it can probably go away.
#  def self.list_from_cloud_tag( type, tag, user=nil, offset=0, limit=nil )
#    type = type.to_sym
#    offset = offset.to_i
#    limit = limit.nil? ? DOCUMENT_LIMIT : limit.to_i
#
#     if user.nil? 
#       list = find_by_sql([ "#{LIST_SQL_SELECT} #{LIST_BY_TAG_SQL[type]} #{LIST_SQL_ORDER_AND_LIMIT}", tag, offset, limit ]) 
#       count = find_by_sql([ "#{LIST_SQL_COUNT} #{LIST_BY_TAG_SQL[type]}", tag ]).first.hits.to_i
#     else
#       list = find_by_sql([ "#{LIST_SQL_SELECT} #{LIST_BY_USER_BY_TAG_SQL[type]} #{LIST_SQL_ORDER_AND_LIMIT}", tag, user, offset, limit ]) 
#       count = find_by_sql([ "#{LIST_SQL_COUNT} #{LIST_BY_USER_BY_TAG_SQL[type]}", tag, user ]).first.hits.to_i
#     end      
#     
#     return list, count
#  end   
  
  def self.get_hit_from_uri(uri)
    cr = CachedResource.find_by_uri(uri)
    return nil if cr == nil
    return get_hit_from_resource_id(cr.id)
  end
  
  def self.get_image_from_uri(uri)
    hit = CachedResource.get_hit_from_uri(uri)
  	return nil unless hit
    return self.get_image_from_hit(hit)
  end
  
  def self.get_image_from_hit(hit)
    image = self.solr_obj_to_str(hit['image'])
    if image == nil
      image = self.get_thumbnail_from_hit(hit)
    end
    return image
  end
  
  def self.get_thumbnail_from_uri(uri)
   hit = CachedResource.get_hit_from_uri(uri)
    return nil unless hit
    return self.get_thumbnail_from_hit(hit)
  end
  
  def self.get_thumbnail_from_hit(hit)
    image =  self.solr_obj_to_str(hit['thumbnail'])
    return image if image != nil

    site = Site.find_by_code(hit['archive'])
    return nil if site == nil
    
    return self.solr_obj_to_str(site.thumbnail)
  end
  
  def self.get_thumbnail_from_hit_no_site(hit)
    image =  self.solr_obj_to_str(hit['thumbnail'])
    return image
  end
  
  def self.get_link_from_uri(uri)
    hit = CachedResource.get_hit_from_uri(uri)
    return nil unless hit
    return self.get_link_from_hit(hit)
  end
  
  def self.get_link_from_hit(hit)
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
  
  # overrides dynamic find method +find_or_create_by_uri+ so that it can take/return a list
  # TODO-PER: Not sure this is called anywhere.
#  def self.resources_by_uri( uri )
#
#    if uri.kind_of?(Array) 
#      uri.collect { |u| find_or_create_by_uri(u) }.flatten
#    else       
#      find_or_create_by_uri(uri)
#    end
#  end
  
  def self.get_page_of_hits_by_user(user, page_num, items_per_page)
    items = CollectedItem.find(:all, :conditions => ["user_id = ?", user.id], :order => 'updated_at DESC' )
    return self.get_page_of_results(items, page_num, items_per_page)
  end

  # this returns all the objects that the user has collected.
#  def self.get_all_collections(user) # Pass in the actual user object (not just the user name), and get back an array of results. Each result is a hash of all the properties that were cached.
#    items = CollectedItem.find(:all, :conditions => ["user_id = ?", user.id] )
#    results = []
#    items.each { |item|
#      hit = get_hit_from_resource_id(item.cached_resource_id)
#      results.insert(-1, hit)
#    }
#    return results
#  end
   
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
  
  def self.get_page_of_hits_for_tag(tag_name, user, page_num, items_per_page)
    tag = Tag.find_by_name(tag_name)
    # It's possible for this to return nil if a tag was deleted before this request was made.
    return { :results => [], :total => 0 } if tag == nil
    
    items = []
    item_ids = Tagassign.find(:all, :conditions => [ "tag_id = ?", tag.id ] )
    # item_ids are ids into the collected_items table.
    item_ids.each { |item_id|
      coll_item = CollectedItem.find_by_id(item_id.collected_item_id)
      if coll_item != nil && (user == nil || coll_item.user_id == user.id)
        items.insert(-1, coll_item) if !items.detect {|item| item.cached_resource_id == coll_item.cached_resource_id} 
      end
    }
    return self.get_page_of_results(items, page_num, items_per_page)
  end
  
#  def self.get_all_untagged(user)
#    return [] if user == nil
#    items = CollectedItem.find(:all, :conditions => ["user_id = ?", user.id] )
#    results = []
#    items.each { |item|
#      first_tag = Tagassign.find(:first, :conditions => ["collected_item_id = ?", item.id])
#      if !first_tag
#        hit = get_hit_from_resource_id(item.cached_resource_id)
#        results.insert(-1, hit)
#      end
#    }
#    return results
#  end
  
  def self.get_page_of_all_untagged(user, page_num, items_per_page)
    return { :results => [], :total => 0 } if user == nil
    all_items = CollectedItem.find(:all, :conditions => ["user_id = ?", user.id], :order => 'updated_at DESC'  )
    items = []
    all_items.each { |item|
      first_tag = Tagassign.find(:first, :conditions => ["collected_item_id = ?", item.id])
      if !first_tag
        items.insert(-1, item)
      end
    }
    return self.get_page_of_results(items, page_num, items_per_page)
  end
  
  # get a list of all tags for a particular user. Pass in the actual user object (not just the user name), and get back a hash
  # of key=uri, value=array of tags
#  def self.get_all_of_users_collections(user) # TODO: PER- I think this is out of date, but not sure.
#    all_books = Hash.new
#    cloud_freq = self.get_all_tags(user) # get a list of all the tags
#    cloud_freq.each { |entry| # entry is an array. The first element is the tag name.
#      tag = entry[0]
#      data = self.get_all_items_by_tag(tag, user )  # for each tag, get a list of all the books that are tagged
#      if data != nil
#        data.each { |item|  # item is a class with a member named @attributes. That is a hash where 'uri' is the key we are interested in.
#          uri = item.attributes['uri']
#          tag_list = all_books[uri]
#          tag_list = Array.new if tag_list == nil
#          tag_list.insert(-1, tag)
#          all_books[uri] = tag_list
#        }
#      end
#      #uri = data.attributes[:uri]
#      #all_books[:uri] = tag
#    }
#    
#    return all_books  # return the rearranged data: the key is the book so it is easy to search in the way we need.
#  end
  
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
      resource.properties.each do |prop|
        properties << CachedProperty.new(:name => prop.name, :value => prop.value)
      end
    end
  
#    def self.get_all_tags(user)
#      cloud_of_ar_objects = find_by_sql([ CLOUD_BY_USER_SQL[:all_tags], user.id ])
#           
#      # convert active record objects to [name,freq] pairs
#      unless cloud_of_ar_objects.nil?  
#        return cloud_of_ar_objects.map { |entry| [ entry.name, entry.freq.to_i ] }
#      else
#        return []
#      end
#    end

#    def self.get_all_items_by_tag(tag, user)
#      list = find_by_sql([ "#{LIST_SQL_SELECT} #{LIST_BY_USER_BY_TAG_SQL[:tag]}", tag, user ]) 
#       
#      return list
#    end   

  public
  def self.get_hit_from_resource_id(resource_id)
    hit = {}
    uri = CachedResource.find(resource_id)
    hit['uri'] = uri.uri
    properties = CachedProperty.find(:all, {:conditions => ["cached_resource_id = ?", resource_id]})
    properties.each do |property|
      if !hit[property.name]
        hit[property.name] = []
      end
      if property.name == 'title'
        bytes = ""
        property.value.each_byte { |c| bytes += "#{c} " if c > 127 }
        hit[property.name].insert(-1, property.value + bytes)
      else
        hit[property.name].insert(-1, property.value)
      end
    end
    return hit
  end

#  def self.single_table_get_hit_from_resource_id(resource_id)
#    cr = CachedResource.find(resource_id)
#    hit = {}
#    hit['uri'] = cr.uri
##    properties = CachedProperty.find(:all, {:conditions => ["cached_resource_id = ?", resource_id]})
#
#    # The old way of storing properties was in the separate properties table. Now we store them in a single field
#    # in this table and parse them as a string. This is for efficiency.
#
#    # We first check to see if the properties field is used. If so, then just return it. If not, then look for the
#    # properties in the old table and write them to the properties field.
#    str = cr.attributes['properties']
#    if str == nil
#      props = cr.cached_properties
##      prop_hash = { }
##      properties.each do |property|
##        if !prop_hash[property.name]
##          prop_hash[property.name] = []
##        end
##        prop_hash[property.name].insert(-1, property.value)
##      end
#      
#      str = ""
#      props.each { |prop| 
#        str += prop.name + "\t" + prop.value + "\n"
#      }
#      cr.properties = str
#      cr.save
#    end
#
#    prop_arr = str.split("\n")
#    prop_arr.each do |prop_str|
#      prop = prop_str.split("\t")
#      if !hit[prop[0]]
#        hit[prop[0]] = []
#      end
#      hit[prop[0]].insert(-1, prop[1])
#    end
#    
##    hit['thumbnail'] = [ "http://www.rossettiarchive.org/img/thumbs_small/s77.jpg" ]
##    hit['role_AUT'] = [ "Jerome J. McGann"  ]
###    hit['uri'] = "http://www.rossettiarchive.org/docs/s77.raw"
##    hit['archive'] = [ "rossetti" ]
##    hit['title'] = [ 'Commentary for Cats Cradle' ]
##    hit['date_label'] = [ '2008' ]
##    hit['url'] = [ "http://www.rossettiarchive.org/docs/s77.raw.html" ]
##    hit['genre'] = [ "Criticism" ]
##    hit['image'] = [ "http://www.rossettiarchive.org/img/s77.jpg" ]
#    return hit
#  end
  
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
