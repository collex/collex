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

class DropGen1CacheTables < ActiveRecord::Migration
  def self.up
    drop_table :agent_types
    drop_table :cached_agents
    drop_table :cached_dates
    drop_table :cached_documents
    drop_table :cached_documents_genres
    drop_table :cached_documents_tags
    drop_table :genres
  end

  # Make sure we have these classes available for self.down
  class CachedAgent < ActiveRecord::Base
    belongs_to :agent_type
  end
  class AgentType < ActiveRecord::Base 
    has_many :cached_agents 
  end
  
  def self.down  
    create_table "agent_types", :force => true do |t|
      t.column "name", :string
    end
    
    create_table "cached_agents", :force => true do |t|
      t.column "name",               :string
      t.column "agent_type_id",      :integer
      t.column "cached_document_id", :integer
    end
    
    create_table "cached_dates", :force => true do |t|
      t.column "date",               :string
      t.column "cached_document_id", :integer
    end
    
    create_table "cached_documents", :force => true do |t|
      t.column "uri",     :string
      t.column "title",   :string
      t.column "archive", :string
    end
    
    create_table "cached_documents_genres", :id => false, :force => true do |t|
      t.column "cached_document_id", :integer
      t.column "genre_id",           :integer
    end
    
    create_table "cached_documents_tags", :id => false, :force => true do |t|
      t.column "cached_document_id", :integer
      t.column "tag_id",             :integer
    end
    
    create_table "genres", :force => true do |t|
      t.column "name", :string
    end
    # NOTE this execute statement will have problems if any entries have more than one title or archive
    execute "insert into cached_documents (id, uri, title, archive) 
             select cr.id, cr.uri, cp.value as title, cp2.value as archive from cached_resources as cr 
             join cached_properties cp on cr.id=cp.cached_resource_id 
             join cached_properties cp2 on cr.id = cp2.cached_resource_id where cp.name='title' and cp2.name='archive'"
   
    # import the genres fixtures into genres table and populate cached_documents_genres
    # NOTE this will skip any genres in the cached_properties table that are not listed in the fixture.
    Fixtures.create_fixtures(File.dirname(__FILE__), "genres") 
    execute "insert into cached_documents_genres (cached_document_id, genre_id) 
             select cp.cached_resource_id, g.id from cached_properties cp 
             join genres g on g.name=cp.value where cp.name='genre'"
    
    # populate the cached_agents and agent_types tables
    props = CachedProperty.find(:all, :conditions => "name like 'role_%'")
    props.each do |prop|
      agent = CachedAgent.new(:name => prop.value, :cached_document_id => prop.cached_resource_id)
      agent.agent_type = AgentType.find_or_create_by_name(prop.agent_type)
      agent.save
    end
    
    # put existing dates into the cached_dates table
    execute "insert into cached_dates (date, cached_document_id) 
             select value as date, cached_resource_id as cached_document_id 
             from cached_properties where name='date' or name = 'date_label'"
  end
end
