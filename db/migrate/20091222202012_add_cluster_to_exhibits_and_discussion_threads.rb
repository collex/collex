class AddClusterToExhibitsAndDiscussionThreads < ActiveRecord::Migration
  def self.up
    add_column :exhibits, :cluster_id, :decimal
    add_column :discussion_threads, :cluster_id, :decimal
  end

  def self.down
    remove_column :discussion_threads, :cluster_id
    remove_column :exhibits, :cluster_id
  end
end
