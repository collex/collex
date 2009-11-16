class AddLinkTitleToDiscussionComments < ActiveRecord::Migration
  def self.up
    add_column :discussion_comments, :link_title, :string
  end

  def self.down
    remove_column :discussion_comments, :link_title
  end
end
