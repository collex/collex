class CreateDiscussionThreads < ActiveRecord::Migration
  def self.up
    create_table :discussion_threads do |t|
      t.integer :discussion_topic_id
      t.string :title

      t.timestamps
    end
  end

  def self.down
    drop_table :discussion_threads
  end
end
