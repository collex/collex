class CreateCollectedItems < ActiveRecord::Migration
  def self.up
    create_table :collected_items do |t|
      t.decimal :user_id
      t.decimal :cached_resource_id
      t.decimal :tag_id
      t.text :annotation
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :collected_items
  end
end
