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

class DiscussionVisit < ActiveRecord::Base
	def self.visited(thread_rec, user)
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
