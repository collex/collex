class CreateFeaturedObjects < ActiveRecord::Migration
  def self.up
    create_table :featured_objects do |t|
      t.string :object_uri
      t.string :title
      t.string :object_url
      t.string :date
      t.string :site
      t.string :site_url
      t.string :saved_search_name
      t.string :saved_search_url
      t.decimal :image_id
      t.string :disabled

      t.timestamps
    end
  end

  def self.down
    drop_table :featured_objects
  end
end
