class RemoveReportFromDiscussionComment < ActiveRecord::Migration
  def self.up
    
    # get all of the existing comments that have been reported
    comments = DiscussionComment.where('reported is not null')
    
    # migrate this informationover to the new comment_reports table
    comments.each do |comment|
      id_list = comment.reporter_ids
      id_list.split(',').each do | reporter_id |
        comment.comment_reports.create(:discussion_comment_id=>comment.id, :reason=>'N/A - Migrated', :reporter_id=>reporter_id, :reported_on=>Time.now) 
      end 
      comment.save
    end
    
    # once data has been migrated, retire the columns in the comments table
    remove_column :discussion_comments, :reported
    remove_column :discussion_comments, :reporter_ids
  end

  def self.down
    # first, add back the prior columns
    add_column :discussion_comments, :reported, :integer
    add_column :discussion_comments, :reporter_ids, :text
    
    # get all of the entries in the comment_reports table
    reports = CommentReport.all
    
    curr_comment_id = nil
    ids = ''
    reports.each do |report|
      
      # collect all of the reporter_ids for reports on the same comment_id
      if curr_comment_id != report.discussion_comment_id
        
        # once a change in id is detected, dump the data into the comment
        if ids.length > 0 && !curr_comment_id.nil?
          comment = DiscussionComment.find(curr_comment_id)  
          comment.reported = 1
          comment.reporter_ids = ids
          comment.save
        end
        
        # reset reporter id list and make this comment current
        curr_comment_id = report.discussion_comment_id
        ids = report.reporter_id.to_s()
      else
        ids = ids + "," + report.reporter_id.to_s()
      end
    end
    
    # update the last coment
    if ids.length > 0 && !curr_comment_id.nil?
      comment = DiscussionComment.find(curr_comment_id)  
      comment.reported = 1
      comment.reporter_ids = ids
      comment.save
    end
    
    # clean out the migrated data
    ActiveRecord::Base.connection.execute('truncate comment_reports')
        
  end
end
