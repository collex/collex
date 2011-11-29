class ChangeReporterIdToReporterIdsInDiscussionComments < ActiveRecord::Migration
  def self.up
    add_column :discussion_comments, :reporter_ids, :text
    remove_column :discussion_comments, :reporter_id
    #DiscussionComment.clear_all_report_flags()
  end

  def self.down
    remove_column :discussion_comments, :reporter_ids
    add_column :discussion_comments, :reporter_id, :decimal
  end
end
