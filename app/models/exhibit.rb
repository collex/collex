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

class Exhibit < ActiveRecord::Base
  include SolrMixin

  belongs_to :user
  belongs_to :license
  belongs_to :exhibit_type
  has_many :exhibited_pages, :order => "position", :dependent => :destroy
  alias_method :pages, :exhibited_pages
  
  validates_presence_of :title, :exhibit_type_id, :user_id, :license
  
  def template
    self.exhibit_type.template
  end
  
  def indexed?
    (! uri.blank?) and solr.indexed?(uri)
  end
  
  # If not indexed, creates uri, adds exhibit to the index.
  # Otherwise, updates the exisiting document in solr.
  # uri
  # url
  # archive--"nines"?
  # author (role_aut)
  # exhibit type
  # status: published or shared
  # license
  # genres
  # fulltext of exhibit content (not the contained objects)
  # displayed metadata from the contained objects
  # TODO 'genre' is specific to the nines index and should not be coded in Exhibit/ExhibtedPage/ExhibitedSection/ExhibitedResource
  # Instead, we need a way to configure installation-specific object fields for indexing in the Exhibit.
  def index!
    if indexed?
      self.solr.connection.delete("#{self.uri}")
      self.solr.connection.commit
    end
    if self.uri.blank?
      self.uri = UUID.new
      save!
    end
    
    map = { :uri => self.uri, 
            :url => "#{EXHIBITS_CONF['base_url']}/exhibits/#{self.uri}",
            :title => self.titles, 
            :archive => EXHIBITS_CONF["archive"],
            :role_AUT => self.user.fullname,
            :exhibit_type => self.exhibit_type.description,
            :published => self.published?,
            :license => self.license.name,
            :text => self.annotations,
            :genre => self.resources.collect { |r| r.properties.inject([]) { |a,p| a << p.value if p.name == 'genre'; a } }.flatten.uniq      
          }
    
    response = self.solr.connection.add(map)
    self.solr.connection.commit
    response
  end
  
  def uris
    self.pages.collect { |page| page.uris }.flatten
  end
  
  def sections
    self.exhibited_pages.collect { |ep| ep.exhibited_sections }.flatten
  end

  # Collection of all the +ExhibitedResource+s in the +Exhibit+
  def exhibited_resources
    self.sections.collect { |s| s.resources }.flatten
  end
  alias_method :resources, :exhibited_resources
  
  # An array of all annotations in the Exhibit, from +ExhibitedPage+s, +ExhibitedSection+s, +ExhibitedItem+s
  # This is a convenience for indexing the text in an +Exhibit+
  def annotations
    array = self.annotation.blank? ? [] : [self.annotation]
    self.pages.inject(array) do |array, page|
      array << page.annotation unless page.annotation.blank?
      page.sections.each do |section|
        array << section.annotation unless section.annotation.blank?
        section.items.each do |item|
          array << item.annotation unless item.annotation.blank?
        end
      end
      array
    end
  end
  
  # An array of all titles in the Exhibit, from +ExhibitedPage+s, +ExhibitedSection+s, +ExhibitedItem+s
  # This is a convenience for indexing the text in an +Exhibit+
  def titles
    array = self.title.blank? ? [] : [self.title]
    self.pages.inject(array) do |array, page|
      array << page.title unless page.title.blank?
      page.sections.each do |section|
        array << section.title unless section.title.blank?
      end
      array
    end
  end
  
  def title_message
    exhibit_type.title_message
  end
  
  def annotation_message
    exhibit_type.annotation_message
  end
  
  def valid_page_types
    exhibit_type.page_types
  end
  
  # Takes a User object or a user_id
  def owner?(user)
    user.is_a?(Integer) ? self.user_id == user : self.user_id == user.id rescue false
  end
  
  def share!
    self.shared  = true
  end
  
  # Will throw an error if +published+ is true
  def unshare!
    self.shared = false
  end
  
  # When the value is +true+, just pass through.
  # When the value is +false+, throw an error if the exhibit is published.
  def shared=(value)
    case value
    when true
      write_attribute(:shared, value)
    when false
      published? ? raise(Exception, ("Can not unshare a published exhibit.")) : write_attribute(:shared, value)
    end
  end
  
  # Will throw an error if is called when +shared+ is +false+.
  def publish!
    self.published = true
  end
  def unpublish!
    self.published = false
  end
  
  # Will throw an error if value is +true+ when +shared+ is +false+.
  def published=(value)
    publishable? ? write_attribute(:published, value) : raise(Exception, ("Can not publish an unshared exhibit. You must share it first."))
  end
    
# Permissions
  def publishable?
    shared?
  end
  
  def deletable?
    !published?
  end
  
  def sharable?
    !shared and !published?
  end

  def viewable_by?(viewer)
    shared? or updatable_by?(viewer)
  end

  def updatable_by?(editor)
    (!published? and (editor == user or editor.editor_role?)) or editor.admin_role?
  end

  def deletable_by?(deleter)
    deletable? and updatable_by?(deleter)
  end

  def creatable_by?(creator)
    !creator.guest_role?
  end
  
  def sharable_by?(sharer)
    sharable? and updatable_by?(sharer)
  end
  
  def unsharable_by?(sharer)
    !published? and shared? and updatable_by?(sharer)
  end
  
  def publishable_by?(publisher)
     publishable? and (publisher.admin_role? or publisher.editor_role?)
  end
end
