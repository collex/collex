class CreateCachedDocumentsTags < ActiveRecord::Migration
  def self.up
    create_table :cached_documents_tags, :id => false do |t|
      t.column :cached_document_id, :integer
      t.column :tag_id, :integer
    end
  end

  def self.down
    drop_table :cached_documents_tags
  end
end
