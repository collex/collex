class CreateCachedDocuments < ActiveRecord::Migration
  def self.up
    create_table :cached_documents do |t|
      t.column :uri, :string
      t.column :title, :string
      t.column :date_label, :string
      t.column :archive, :string 
    end
  end

  def self.down
    drop_table :cached_documents
  end
end
