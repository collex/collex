##########################################################################
# Copyright 2009 Applied Research in Patacriticism and the University of Virginia
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################

class DiscussionComment < ActiveRecord::Base
  belongs_to :discussion_thread
  belongs_to :cached_resource
  belongs_to :exhibit
  acts_as_list :scope => :discussion_thread
  before_save :b4_save
  has_many :comment_reports, :dependent => :destroy

  after_save :handle_solr

 	def handle_solr
 		SearchUserContent.delay.index('thread', self.discussion_thread.id)
 	end

  # Return true if this comment has been reported as abusive by anyone
  #
  def reported
    return comment_reports.length > 0
  end
  
  # Return true if user_id has already reported this comment as abusive
  #
  def has_been_reported_by(user_id)
    return false if comment_reports.length == 0
    
    comment_reports.each { |report|
      if report.reporter_id == user_id
        return true
      end
    }
    return false
  end
  
  # Get a list of users that have reported this comment as abusive
  #
  def get_reporters()
    reporters = []
    comment_reports.each do |report|
      reporters.push( User.find(report.reporter_id) )
    end  
    return reporters
  end
  
  # Get a comma separated list of usernames that have reported this comment
  # as abusive
  #
  def get_reported_by_list()
    names = []
    comment_reports.each do |report|
  		user = User.find_by_id(report.reporter_id)
  		if user
  			names.push(user.fullname)
  		else
  			names.push("User not found: #{report.reporter_id}")
  		end
    end
    return names.join(", ")
  end

  # reporter_id finds this comment abusive for the specified reason. Mark it as such
  # in the database
  #
  def add_reporter( reporter_id, reason )
    comment_reports.create(
      :discussion_comment_id => id, 
      :reason => reason, 
      :reporter_id => reporter_id, 
      :reported_on => Time.now)
  end
  
  def b4_save
    a = @attributes
    c = a['comment_type']
    if c == 'comment'
      comment_type = 1
    elsif c == 'nines_object'
      comment_type = 2
    elsif c == 'nines_exhibit'
      comment_type = 3
    elsif c == 'inet_object'
      comment_type = 4
    elsif c == 1 || c == 2 || c == 3 || c == 4
      comment_type = c
    elsif c == "1" || c == "2" || c == "3" || c == "4"
      comment_type = c
    else
      comment_type = -1
    end
    @attributes['comment_type'] = comment_type
    attributes['comment_type'] = comment_type
  end

  def get_type
    case comment_type
      when 1 then return "comment"
      when 2 then return "nines_object"
      when 3 then return "nines_exhibit"
      when 4 then return "inet_object"
      else return nil
    end
  end

	def self.delete_comment(id, session_user, is_admin)
		# if the comment is the main comment, then it can only be deleted if there are no subsequent comments.
		# Also, we normally want to stay on the same thread after deleting the comment, but if we just deleted the
		# main comment, then we need to go back to the index. We return -1 for the thread in that case.
		discussion_comment = DiscussionComment.find(id)
		thread_id = discussion_comment.discussion_thread_id

		if !is_admin && session_user.id != discussion_comment.user_id
			# don't delete it unless the user has the authority.
		else
			ok_to_delete = true
			if discussion_comment.position == 1 # the first comment is privileged and will delete the thread
				if discussion_comment.discussion_thread.discussion_comments.length == 1 # only delete the first comment if there are no follow up comments
					discussion_comment.discussion_thread.delete
					thread_id = -1
				else
					ok_to_delete = false
				end
			end
		end
		discussion_comment.destroy if ok_to_delete
		return thread_id
	end

	def self.remove_abuse_report(comment_id, report_id, url)
		discussion_comment = DiscussionComment.find(comment_id)
	  discussion_comment.comment_reports.each { | report |
		  if report.id == report_id.to_i()
    		begin
  				user = User.find(report.reporter_id)
  				body = "The administrator rejected your report of the comment by #{User.find(discussion_comment.user_id).fullname} with the text:\n\n"
  				body += "#{self.strip_tags(discussion_comment.comment)}\n\n"
  				GenericMailer.generic(Setup.site_name(), Setup.return_email(), user.fullname, user.email, 
  				  "Abusive Comment Report Canceled", body, url, "").deliver
    		rescue Exception => msg
    			logger.error("**** ERROR: Can't send email: " + msg.message)
    		end
    		
    		discussion_comment.comment_reports.delete report
    		discussion_comment.save
    		break
    	end
  	}
	end

	def self.strip_tags(str)
		ret = ""
		arr = str.split('<')
		arr.each {|el|
			gt = el.index('>')
			if gt
				ret += el.slice(gt+1..el.length-1) + ' '
			else
				ret += el
			end
		}
		ret = ret.gsub("&nbsp;", " ")
		return ret
	end

end
