class CreateCachedDocumentsGenres < ActiveRecord::Migration
  def self.up
    create_table :cached_documents_genres, :id => false do |t|
      t.column :cached_document_id, :integer
      t.column :genre_id, :integer
    end
  end

  def self.down
    drop_table :cached_documents_genres
  end
end
