class CreateCachedResources < ActiveRecord::Migration
  # In order to facilitate a gradual refactoring and reimplemtation of the caching,
  # cached_resources is just a straight copy of cached_documents rather than a renaming
  # the changed name is to create consistency with the general use of "resource" in the 
  # application to refer to Solr documents.
  def self.up
    create_table :cached_resources do |t|
      t.column :uri, :string
    end
    execute "insert into cached_resources select id, uri from cached_documents"    
    add_index :cached_resources, :uri
  end

  def self.down
    remove_index :cached_resources, :uri
    drop_table :cached_resources
  end
end
