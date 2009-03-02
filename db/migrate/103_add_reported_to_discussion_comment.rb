class AddReportedToDiscussionComment < ActiveRecord::Migration
  def self.up
    add_column :discussion_comments, :reported, :integer
  end

  def self.down
    remove_column :discussion_comments, :reported
  end
end
