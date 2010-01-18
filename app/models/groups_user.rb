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
end
