class AddGroupIdToDiscussionThreads < ActiveRecord::Migration
  def self.up
    add_column :discussion_threads, :group_id, :decimal
  end

  def self.down
    remove_column :discussion_threads, :group_id
  end
end
