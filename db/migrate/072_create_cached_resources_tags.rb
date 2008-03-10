class CreateCachedResourcesTags < ActiveRecord::Migration
  def self.up
    create_table :cached_resources_tags, :id => false do |t|
      t.column :cached_resource_id, :integer
      t.column :tag_id, :integer
    end
    #copy over existing cached_documents_tags into this table
    execute "insert into cached_resources_tags (cached_resource_id, tag_id) select cached_document_id as cached_resource_id, tag_id from cached_documents_tags"
  end

  def self.down
    drop_table :cached_resources_tags
  end
end
