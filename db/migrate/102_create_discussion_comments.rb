class CreateDiscussionComments < ActiveRecord::Migration
  def self.up
    create_table :discussion_comments do |t|
      t.integer :discussion_thread_id
      t.integer :user_id
      t.integer :position
      t.integer :comment_type
      t.integer :cached_resource_id
      t.integer :exhibit_id
      t.string :link_url
      t.string :image_url
      t.text :comment
      t.integer :reported
      t.integer :reporter_id

      t.timestamps
    end
  end

  def self.down
    drop_table :discussion_comments
  end
end
