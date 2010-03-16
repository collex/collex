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
  
  def self.clear_all_report_flags
    comments = DiscussionComment.all
    comments.each { |comment|
      if comment.reported != nil || comment.reported != 0
        comment.update_attribute(:reported, 0)
      end
    }
  end
  
  def has_been_reported_by(user_id)
    # This returns true if the user has reported this comment
    return false if reporter_ids == nil
    
    ids = reporter_ids.split(',')
    ids.each { |id|
      if id == "#{user_id}"
        return true
      end
    }
    return false
  end
  
  def get_reported_by_list()
    ids = reporter_ids.split(',')
    names = []
    ids.each { |id|
      names.push(User.find(id).fullname)
    }
    return names.join(", ")
  end

	def has_reporter(user_id)
		return false if reporter_ids == nil
		
		ids = reporter_ids.split(',')
		i = ids.index("#{user_id}")
		return i != nil
	end

  def self.add_reporter(comment, id)
    ids = "#{id}"
    if comment.reporter_ids != nil && comment.reporter_ids.length > 0
      ids = ids + "," + comment.reporter_ids
    end
    comment.reporter_ids = ids
  end
  
  def before_save
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
      when 1: return "comment"
      when 2: return "nines_object"
      when 3: return "nines_exhibit"
      when 4: return "inet_object"
      else return nil
    end
  end

	def self.delete_comment(id, session_user, is_admin)
		# if the comment is the main comment, then it can only be deleted if there are no subsequent comments.
		# Also, we normally want to stay on the same thread after deleting the comment, but if we just deleted the
		# main comment, then we need to go back to the index. We return -1 for the thread in that case.
		discussion_comment = DiscussionComment.find(id)
		thread_id = discussion_comment.discussion_thread_id

		user = User.find_by_username(session_user[:username])
		if !is_admin && user.id != discussion_comment.user_id
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

	def self.remove_abuse_flag(id, url)
		discussion_comment = DiscussionComment.find(id)
		reporter_ids = discussion_comment.reporter_ids
		discussion_comment.update_attributes({ :reported => nil, :reporter_ids => nil })
		begin
			ids = reporter_ids.split(',')
			ids.each { |reporter_id|
				user = User.find(reporter_id)
				#LoginMailer.deliver_cancel_abuse_report_to_reporter({ :comment => discussion_comment }, user.email)
				body = "The administrator rejected your report of the comment by #{User.find(discussion_comment.user_id).fullname} with the text:\n\n"
				body += "#{self.strip_tags(discussion_comment.comment)}\n\n"
				EmailWaiting.cue_email(SITE_NAME, ActionMailer::Base.smtp_settings[:user_name], user.fullname, user.email, "Abusive Comment Report Canceled", body, url, "")
			}
		rescue Exception => msg
			logger.error("**** ERROR: Can't send email: " + msg)
		end
	end

	private
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
