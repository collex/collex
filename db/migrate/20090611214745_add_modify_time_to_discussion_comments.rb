class AddModifyTimeToDiscussionComments < ActiveRecord::Migration
  def self.up
    add_column :discussion_comments, :user_modified_at, :datetime
  end

  def self.down
    remove_column :discussion_comments, :user_modified_at
  end
end
