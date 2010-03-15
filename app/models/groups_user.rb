# ------------------------------------------------------------------------
#     Copyright 2009 Applied Research in Patacriticism and the University of Virginia
# 
#     Licensed under the Apache License, Version 2.0 (the "License");
#     you may not use this file except in compliance with the License.
#     You may obtain a copy of the License at
# 
#         http://www.apache.org/licenses/LICENSE-2.0
# 
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.
# ----------------------------------------------------------------------------

class GroupsUser < ActiveRecord::Base
	def self.request_join(group_id, user_id)
		gu = self.find_by_group_id_and_user_id(group_id, user_id)
		if gu == nil	# guard against multiple requests coming in.
			user = User.find(user_id)
			gu = GroupsUser.new(:group_id => group_id, :user_id => user_id, :email => user.email, :role => 'member', :pending_invite => false, :pending_request => true)
			gu.save!
			group = Group.find(group_id)
			editors = group.get_all_editors()
			editors.each { |editor|
				ed = User.find(editor)
				LoginMailer.deliver_request_to_join_group({ :name => user.fullname, :email => user.email, :institution => user.institution, :group_name => group.name, :request_id => gu.id, :has_joined => user_id != nil }, ed.email)
			}
		end
	end

	def self.auto_join(group_id, user_id)
		# this is not called from the UI, but by a rake task that automatically joins members that should be joined.
		gu = self.find_by_group_id_and_user_id(group_id, user_id)
		if gu == nil	# guard against multiple requests coming in.
			user = User.find(user_id)
			gu = GroupsUser.new(:group_id => group_id, :user_id => user_id, :email => user.email, :role => 'member', :pending_invite => false, :pending_request => false)
			gu.save!
		end
	end

	def self.accept_request(id)
		id = Group.id_retriever(id)
		gu = self.find_by_id(id)
		if gu != nil
			gu.pending_request = false
			gu.save!
			return true
		end
		return false
	end

	def self.decline_request(id)
		id = Group.id_retriever(id)
		gu = self.find_by_id(id)
		if gu != nil
			gu.destroy
			return true
		end
		return false
	end

	def self.has_login(id)
		id = Group.id_retriever(id)
		gu = self.find_by_id(id)
		if gu != nil
			if gu.user_id != nil
				return true
			else
				user = COLLEX_MANAGER.find_by_email(gu.email)
				return user != nil
			end
		end
		throw "Not found"
	end

	def self.join_group(id)
		id = Group.id_retriever(id)
		gu = self.find_by_id(id)
		if gu != nil
			user = COLLEX_MANAGER.find_by_email(gu.email)
			gu.user_id = user.id if user != nil
			gu.pending_invite = false
			gu.save!
			return true
		end
		return false
	end

	def self.decline_group(id)
		id = Group.id_retriever(id)
		gu = self.find_by_id(id)
		if gu != nil
			gu.destroy
			return true
		end
		throw "Not found"
	end

	def self.leave_group(group_id, user_id)
		gu = self.find_by_group_id_and_user_id(group_id, user_id)
		if gu != nil
			gu.destroy
		end
	end

	def self.get_all_pending_requests(group_id)
		return self.find_all_by_group_id_and_pending_request(group_id, true)
	end

	def self.get_group_from_obfuscated_id(obf)
		id = Group.id_retriever(obf)
		gu = self.find_by_id(id)
		return nil if gu == nil
		return gu.group_id
	end

	def self.get_list_of_users_to_notify(group_id, notification_type)
		return "" if group_id == nil || group_id == 0 || group_id == "" || group_id == "0"
		group = Group.find(group_id)
		user_ids = []
		notes = group.notifications.split(';')
		user_ids.push(group.owner) if notes.include?(notification_type)
		members = self.find_all_by_group_id(group_id)
		members.each {|member|
			if member.notifications != nil
				notes = member.notifications.split(';')
				user_ids.push(member.user_id) if notes.include?(notification_type)
			end
		}
		return user_ids
	end

	def self.email_hook(notification_type, group_id, subject, body, return_url)
		return if group_id == nil
		group_id = group_id.to_i
		return if group_id == 0
		user_ids = self.get_list_of_users_to_notify(group_id, notification_type)
		user_ids.each {|user_id|
			user = User.find(user_id)
			EmailWaiting.cue_email(SITE_NAME, ActionMailer::Base.smtp_settings[:user_name], user.fullname, user.email, subject, body, return_url)
		}
	end
	
	def self.set_notifications(group_id, user_id, notes)
		return "" if group_id == nil || group_id == 0 || group_id == "" || group_id == "0"
		return "" if user_id == nil || user_id == 0 || user_id == "" || user_id == "0"
		group_id = group_id.to_i
		user_id = user_id.to_i
		notification = notes.join(';')
		group = Group.find(group_id)
		if (group.owner == user_id)
			group.notifications = notification
			group.save
			return
		end
		gu = self.find_by_group_id_and_user_id(group_id, user_id)
		if gu
			gu.notifications = notification
			gu.save
		end
	end

	def self.get_notifications(group_id, user_id)
		return "" if group_id == nil || group_id == 0 || group_id == "" || group_id == "0"
		return "" if user_id == nil || user_id == 0 || user_id == "" || user_id == "0"
		group_id = group_id.to_i
		user_id = user_id.to_i
		group = Group.find(group_id)
		return "" if group.owner == user_id && group.notifications == nil
		return group.notifications.split(';') if group.owner == user_id

		gu = self.find_by_group_id_and_user_id(group_id, user_id)
		return gu.notifications.split(';') if gu && gu.notifications != nil
		return ""
	end
end
