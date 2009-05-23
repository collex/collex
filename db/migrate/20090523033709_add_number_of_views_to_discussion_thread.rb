class AddNumberOfViewsToDiscussionThread < ActiveRecord::Migration
  def self.up
    add_column :discussion_threads, :number_of_views, :decimal
  end

  def self.down
    remove_column :discussion_threads, :number_of_views
  end
end
