class DiscussionVisit < ActiveRecord::Base
	def self.visited(thread_rec, session_user)
		return if session_user == nil
		user = User.find_by_username(session_user[:username])
		return if user == nil
		rec = DiscussionVisit.first(:conditions => [ 'user_id = ? AND discussion_thread_id = ?', user.id, thread_rec.id])
		if rec
			rec.update_attribute(:last_visit, Time.now())
		else
			DiscussionVisit.create(:user_id => user.id, :discussion_thread_id => thread_rec.id, :last_visit => Time.now())
		end
	end

	def self.user_has_seen_all_comments(user_id, thread_rec)
		rec = DiscussionVisit.first(:conditions => [ 'user_id = ? AND discussion_thread_id = ?', user_id, thread_rec.id])
		return false if rec == nil
		return rec.last_visit >= thread_rec.get_most_recent_comment_time()
	end
end
