class RemoveDateLabelCachedDocuments < ActiveRecord::Migration
  def self.up
    remove_column :cached_documents, :date_label
  end

  def self.down
    add_column :cached_documents, :date_label, :string
  end
end
