class AddDescriptionToDiscussionTopics < ActiveRecord::Migration
  def self.up
    add_column :discussion_topics, :description, :text
  end

  def self.down
    remove_column :discussion_topics, :description
  end
end
