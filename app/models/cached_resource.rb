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
  
  CLOUD_SQL = { 
    :archive => "select value as name, count(value) as freq from cached_properties as props join cached_resources as docs on docs.id=props.cached_resource_id where props.name = 'archive'  group by value order by value limit ?",
    :agent_facet => "select value as name, count(value) as freq from cached_properties as agents join cached_resources as docs on docs.id=agents.cached_resource_id  where agents.name like 'role_%' group by value order by value limit ?", 
    :tag => "select name, count(name) as freq from tags join taggings on tags.id=taggings.tag_id group by name order by name limit ?",
    :genre => "select value as name, count(value) as freq from cached_properties as genres join cached_resources as docs on docs.id=genres.cached_resource_id where genres.name = 'genre'  group by value order by name limit ?",     
    :username => "select username as name, count(username) as freq from users join interpretations as i on users.id=i.user_id group by username order by name limit ?",
    :year => "select value as name, count(value) as freq from cached_properties as dates join cached_resources as docs on dates.cached_resource_id=docs.id where dates.name = 'date_label' group by dates.value order by value limit ?"
  }
  
  CLOUD_BY_USER_SQL = { 
    :archive => "select value as name, count(value) as freq from cached_properties as props join cached_resources as docs on docs.id=props.cached_resource_id join interpretations as i on docs.uri=i.object_uri  where user_id=? and props.name = 'archive' group by value order by value limit ?",
    :agent_facet => "select value as name, count(value) as freq from cached_properties as agents join cached_resources as docs on docs.id=agents.cached_resource_id join interpretations as i on docs.uri=i.object_uri where user_id=? and agents.name like 'role_%' group by value order by value limit ?", 
    :tag => "select name, count(name) as freq from tags join taggings on tags.id=taggings.tag_id join interpretations as i on taggings.interpretation_id=i.id where user_id=? group by name order by name limit ?",
    :genre => "select value as name, count(value) as freq from cached_properties as genres join cached_resources as docs on docs.id=genres.cached_resource_id join interpretations as i on docs.uri=i.object_uri  where user_id=? and genres.name = 'genre' group by value order by value limit ?",
    :username => "select username as name, count(username) as freq from users join interpretations as i on users.id=i.user_id where users.id = ? group by username order by name limit ?",
    :year => "select value as name, count(value) as freq from cached_properties as dates join cached_resources as docs on dates.cached_resource_id=docs.id join interpretations as i on docs.uri=i.object_uri where user_id=? and dates.name = 'date_label' group by dates.value order by value limit ?",
    :all_tags => "select name, count(name) as freq from tags join taggings on tags.id=taggings.tag_id join interpretations as i on taggings.interpretation_id=i.id where user_id=? group by name order by name"
  }
  
  LIST_SQL_SELECT = "select docs.* from cached_resources as docs"
  LIST_SQL_COUNT = "select count(*) as hits from cached_resources as docs"
  LIST_SQL_ORDER_AND_LIMIT = " limit ?,?"
  
  LIST_BY_TAG_SQL = {
    :archive => "join cached_properties props on docs.id = props.cached_resource_id where name='archive' and value=?",
    :agent_facet => "join cached_properties as props on docs.id=props.cached_resource_id where props.name like 'role_%' and props.value = ?", 
    :tag => "join cached_resources_tags as doc_tags on docs.id=doc_tags.cached_resource_id join tags on doc_tags.tag_id=tags.id where tags.name=?", 
    :genre => "join cached_properties as props on docs.id=props.cached_resource_id where props.name = 'genre' and props.value = ?",
    :username => "join interpretations as i on docs.uri=i.object_uri join users on i.user_id=users.id where i.user_id.username=?",
    :year => "join cached_properties as props on docs.id=props.cached_resource_id where props.name = 'date_label' and props.value = ?"
  }

  LIST_BY_USER_BY_TAG_SQL = {
    :archive => "join cached_properties props on docs.id = props.cached_resource_id 
                 join interpretations as i on docs.uri=i.object_uri 
                 where name='archive' and value=? and i.user_id = ?",
    :agent_facet => "join interpretations as i on docs.uri=i.object_uri 
                     join cached_properties as props on docs.id=props.cached_resource_id 
                     where props.name like 'role_%' and props.value = ? and i.user_id = ?", 
    :tag => "join interpretations as i on docs.uri=i.object_uri 
             join cached_resources_tags as doc_tags on docs.id=doc_tags.cached_resource_id 
             join tags on doc_tags.tag_id=tags.id 
             where tags.name=? and i.user_id = ?", 
    :genre => "join interpretations as i on docs.uri=i.object_uri 
               join cached_properties as props on docs.id=props.cached_resource_id 
               where props.name = 'genre' and props.value = ? and i.user_id = ?",   
    :username => "join interpretations as i on docs.uri=i.object_uri 
                  join users on i.user_id=users.id where users.username=? and i.user_id = ?",
    :year => "join interpretations as i on docs.uri=i.object_uri 
              join cached_properties as props on docs.id=props.cached_resource_id 
              where props.name = 'date_label' and props.value = ? and i.user_id = ?"
  }

  DOCUMENT_LIMIT = 1000
  
  # Returns a sorted array of [name,freq] pairs for the specified cloud type and optional user_id
  def self.cloud( type, user=nil, limit=nil )
    type = type.to_sym
    limit = limit.nil? ? DOCUMENT_LIMIT : limit.to_i
          
    cloud_of_ar_objects = if user.nil? 
      find_by_sql([ CLOUD_SQL[type], limit ]) 
    else
      find_by_sql([ CLOUD_BY_USER_SQL[type], user, limit ])
    end      
         
    # convert active record objects to [name,freq] pairs
    unless cloud_of_ar_objects.nil?  
      return cloud_of_ar_objects.map { |entry| [ entry.name, entry.freq.to_i ] }
    else
      return []
    end
  end
  
  # Returns a sorted array of CachedResource objects associated with a given cloud tag and optionally restricts by user
  def self.list_from_cloud_tag( type, tag, user=nil, offset=0, limit=nil )
    type = type.to_sym
    offset = offset.to_i
    limit = limit.nil? ? DOCUMENT_LIMIT : limit.to_i

     if user.nil? 
       list = find_by_sql([ "#{LIST_SQL_SELECT} #{LIST_BY_TAG_SQL[type]} #{LIST_SQL_ORDER_AND_LIMIT}", tag, offset, limit ]) 
       count = find_by_sql([ "#{LIST_SQL_COUNT} #{LIST_BY_TAG_SQL[type]}", tag ]).first.hits.to_i
     else
       list = find_by_sql([ "#{LIST_SQL_SELECT} #{LIST_BY_USER_BY_TAG_SQL[type]} #{LIST_SQL_ORDER_AND_LIMIT}", tag, user, offset, limit ]) 
       count = find_by_sql([ "#{LIST_SQL_COUNT} #{LIST_BY_USER_BY_TAG_SQL[type]}", tag, user ]).first.hits.to_i
     end      
     
     return list, count
  end   
  
  # overrides dynamic find method +find_or_create_by_uri+ so that it can take/return a list
  def self.resources_by_uri( uri )

    if uri.kind_of?(Array) 
      uri.collect { |u| find_or_create_by_uri(u) }.flatten
    else       
      find_or_create_by_uri(uri)
    end
  end
  
  # get a list of all tags for a particular user. Pass in the actual user object (not just the user name), and get back a hash
  # of key=uri, value=array of tags
  def self.get_all_of_users_collections(user)
    all_books = Hash.new
    cloud_freq = self.get_all_tags(user) # get a list of all the tags
    cloud_freq.each { |entry| # entry is an array. The first element is the tag name.
      tag = entry[0]
      data = self.get_all_items_by_tag(tag, user )  # for each tag, get a list of all the books that are tagged
      if data != nil
        data.each { |item|  # item is a class with a member named @attributes. That is a hash where 'uri' is the key we are interested in.
          uri = item.attributes['uri']
          tag_list = all_books[uri]
          tag_list = Array.new if tag_list == nil
          tag_list.insert(-1, tag)
          all_books[uri] = tag_list
        }
      end
      #uri = data.attributes[:uri]
      #all_books[:uri] = tag
    }
    
    return all_books  # return the rearranged data: the key is the book so it is easy to search in the way we need.
  end
  
  private
    #TODO filter out tags and annotations and usernames 
    def copy_solr_resource
      return if resource.nil?
      resource.properties.each do |prop|
        properties << CachedProperty.new(:name => prop.name, :value => prop.value)
      end
    end
  
    def self.get_all_tags(user)
      cloud_of_ar_objects = find_by_sql([ CLOUD_BY_USER_SQL[:all_tags], user.id ])
           
      # convert active record objects to [name,freq] pairs
      unless cloud_of_ar_objects.nil?  
        return cloud_of_ar_objects.map { |entry| [ entry.name, entry.freq.to_i ] }
      else
        return []
      end
    end

    def self.get_all_items_by_tag(tag, user)
      list = find_by_sql([ "#{LIST_SQL_SELECT} #{LIST_BY_USER_BY_TAG_SQL[:tag]}", tag, user ]) 
       
      return list
    end   

end
