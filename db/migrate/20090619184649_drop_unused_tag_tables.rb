class DropUnusedTagTables < ActiveRecord::Migration
  def self.up
   drop_table :interpretations
   drop_table :taggings
   drop_table :cached_resources_tags
  end

  def self.down
    create_table :interpretations do |t|
      t.column :user_id, :integer
      t.column :object_uri, :text
      t.column :annotation, :text
      t.column :created_on,  :datetime
      t.column :updated_on,  :datetime
    end

    create_table :taggings do |t|
      t.column :tag_id, :integer
      t.column :interpretation_id, :integer
      t.column :created_on,  :datetime
    end
    create_table :cached_resources_tags do |t|
      t.column :cached_resource_id, :integer
      t.column :tag_id, :integer
    end
 end
end
