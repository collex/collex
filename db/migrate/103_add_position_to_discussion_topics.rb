class AddPositionToDiscussionTopics < ActiveRecord::Migration
  def self.up
    add_column :discussion_topics, :position, :decimal
    
    topics = DiscussionTopic.all()
    topics.each_with_index do |topic, index|
      topic.position = index + 1
      topic.save
    end
  end

  def self.down
    remove_column :discussion_topics, :position
  end
end
