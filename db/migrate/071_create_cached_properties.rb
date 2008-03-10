class CreateCachedProperties < ActiveRecord::Migration
  def self.up
    create_table :cached_properties do |t|
      t.column :name, :string
      t.column :value, :string
      t.column :cached_resource_id, :integer
    end
    add_index :cached_properties, :name
    add_index :cached_properties, :value
    
    # put existing archive into the cached_properties table
    execute "insert into cached_properties (cached_resource_id, name, value)
         select id as cached_resource_id, 'archive' as name, archive as value 
         from cached_documents"    
    # put existing title into the cached_properties table--there is only one now, but some items have
    # alternate titles that are indexed
    execute "insert into cached_properties (cached_resource_id, name, value)
         select id as cached_resource_id, 'title' as name, title as value 
         from cached_documents"
    # put existing genres into the cached_properties table
    execute "insert into cached_properties (cached_resource_id, name, value)
             select cached_document_id as cached_resource_id, 'genre' as name, name as value 
             from cached_documents_genres as cdt join genres as g on cdt.genre_id=g.id"
    # put existing role_*s into the cached_properties table
    execute "insert into cached_properties (cached_resource_id, name, value)
             select cached_document_id as cached_resource_id, concat('role_', ats.name) as name, agents.name as value 
             from cached_agents as agents join agent_types as ats on agents.agent_type_id=ats.id"
    # put existing dates into the cached_properties table
    execute "insert into cached_properties (cached_resource_id, name, value)
             select cached_document_id as cached_resource_id, 'date_label' as name, date as value 
             from cached_dates"
  end

  def self.down
    remove_index :cached_properties, :name
    remove_index :cached_properties, :value
    drop_table :cached_properties
  end
end
