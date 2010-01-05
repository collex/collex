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

class Group < ActiveRecord::Base
	belongs_to :user, :foreign_key => "owner"
	has_many :exhibits
	has_many :discussion_threads
	has_and_belongs_to_many :users
  belongs_to :image#, :dependent=>:destroy

	#
	# id translation
	#
	def self.id_obfuscator(id) # this just changes the id so it is not apparently predictable to a hacker
		return id.to_i * 1657
	end

	def self.id_retriever(id)	# this undoes the obfuscation
		return id.to_i / 1657
	end

	#
	# User's capabilities
	#
	def self.user_is_in_group(user_id)
		# Does this user belong to at least one group?
		return self.get_all_users_groups(user_id).length > 0
	end

	def can_edit(user_id)
		return is_editor(user_id)
	end

	def self.can_read(thread, user_id)
		return true if thread.group_id == nil
		group = Group.find(thread.group_id)
		return group.can_read_forum(user_id)
	end

	def can_read_forum(user_id)
		return true if self.forum_permissions != 'hidden'
		return is_member(user_id)
	end

	def can_post(user_id)
		return true if self.forum_permissions == 'full'
		return is_member(user_id)
	end

	def can_delete(user_id)
		return is_owner(user_id)
	end

	def can_request_to_join(user_id)
		return false if user_id == nil
		pending_id = get_pending_id(user_id)
		return false if pending_id
		return !is_member(user_id) && !is_request_pending(user_id)
	end

	def can_leave_group(user_id)
		return !is_owner(user_id) && is_member(user_id)
	end

	#
	# Exhibit capabilities
	#
	def self.can_change_license(exhibit)
		return true if exhibit.group_id == nil || exhibit.group_id == 0
		group = Group.find(exhibit.group_id)
		return group.license_type == nil || group.license_type == 0
	end

	def self.can_change_styles(exhibit)
		return true if exhibit.group_id == nil || exhibit.group_id == 0
		group = Group.find(exhibit.group_id)
		return group.use_styles != 1
	end
	#
	# User's Roles
	#
	private
	def is_owner(user_id)
		return user_id == self.owner
	end

	def is_editor(user_id)
		return false if user_id == nil
		return true if is_owner(user_id)
		rec = GroupsUser.find_by_group_id_and_user_id(self.id, user_id)
		return false if rec == nil
		return rec.role == 'editor'
	end

	def is_member(user_id)
		return true if is_owner(user_id)
		rec = GroupsUser.find_by_group_id_and_user_id(self.id, user_id)
		return false if rec == nil
		return false if rec.pending_invite == true || rec.pending_request == true
		return true
	end
	
	public
	def non_clustered_exhibits()
		ret = []
		exhibits = Exhibit.find_all_by_group_id_and_is_published(self.id, '1')
		exhibits.each { |exhibit|
			if exhibit.cluster_id == nil
				ret.push({ :text => exhibit.title, :value => exhibit.id })
			end
		}
		return ret
	end
	
	def get_all_editors()
		gus = GroupsUser.find_all_by_group_id_and_role(self.id, 'editor')
		editors = []
		editors.push(self.owner)
		gus.each { |gu|
			editors.push(gu.user_id)
		}
		return editors
	end

	def self.get_all_users_groups(user_id)
		groups = Group.find_all_by_owner(user_id)
		gu = GroupsUser.find_all_by_user_id(user_id)
		gu.each { |rec|
			if !rec.pending_invite & !rec.pending_request
				groups.push(Group.find(rec.group_id))
			end
		}
		return groups
	end

	def self.is_peer_reviewed_group(exhibit)
		return false if exhibit.group_id == nil
		group = Group.find(exhibit.group_id)
		return group.group_type == 'peer-reviewed'
	end

	def get_pending_id(user_id)
		user = User.find(user_id)
		gu = GroupsUser.find_by_group_id_and_email(self.id, user.email)
		return Group.id_obfuscator(gu.id) if gu != nil && gu.pending_invite == true
		return nil
	end

	def is_request_pending(user_id)
		return false if user_id == nil
		user = User.find(user_id)
		gu = GroupsUser.find_by_group_id_and_email(self.id, user.email)
		return false if gu == nil
		return gu.pending_request == true
	end

	def get_membership_list()
		gus = GroupsUser.find_all_by_group_id(self.id)
		ret = []
		gus.each { |gu|
			if gu.pending_invite == false && gu.pending_request == false
				user = User.find(gu.user_id)
				ret.push({ :name => user.fullname, :user_id => user.id, :id => gu.id, :role => gu.role })
			end
		}
		return ret
	end

	#
	# Actions
	#
	def split_by_all_delimiters(emails)
		ret = []
		arr = emails.split("\n")
		arr.each { |email|
			arr2 = email.split(' ')
			arr2.each { |email2|
				arr3 = email2.split(',')
				arr3.each { |email3|
					arr4 = email3.split(';')
					arr4.each { |email4|
						ret.push(email4)
					}
				}
			}
		}
		return ret
	end

	def invite_members(editor_name, editor_email, emails)
		msgs = ""
		arr = split_by_all_delimiters(emails)
		arr.each { |email|
			email = email.strip()
			if email.length > 0
				user = COLLEX_MANAGER.find_by_email(email)
				if (user == nil)	# either inviting a user who doesn't have a login, or using the login id
					user_id = nil
					user = User.find_by_username(email)
					if user != nil
						user_id = user.id
						email = user.email
					end
				else
					user_id = user.id
				end

				gu = GroupsUser.find_by_group_id_and_email(self.id, email)
				if gu == nil	# don't invite someone twice
					begin
						gu = GroupsUser.new({ :group_id => self.id, :user_id => user_id, :email => email, :role => 'member', :pending_invite => true, :pending_request => false })
						gu.save!
						LoginMailer.deliver_invite_member_to_group({ :group_name => self.name, :editor_name => editor_name, :request_id => gu.id, :has_joined => user_id != nil }, email, editor_email)
					rescue Net::SMTPFatalError
						msgs += "Error sending email to address \"#{email}\".<br />"
						gu.delete
					end
				end
			end
		}
		return nil if msgs.length == 0
		return msgs
	end

	#
	# enumerations
	#
	def self.types()
		return [ 'community', 'classroom', 'peer-reviewed']
	end

	def self.friendly_types()
		return [ 'Community', 'Classroom', 'Peer Reviewed']
	end
	def self.type_to_friendly(type)
		0.upto(self.types.length) { |i|
			return self.friendly_types[i] if self.types()[i] == type
		}
		return ""
	end
	def self.friendly_to_type(type)
		0.upto(self.types.length) { |i|
			return self.types[i] if self.friendly_types()[i] == type
		}
		return ""
	end
	def self.types_to_json(show_all)
		vals = self.types()
		texts = self.friendly_types()
		ret = []
		top = show_all ? 2 : 1
		0.upto(top) { |i|
			ret.push({ :value => vals[i], :text =>	texts[i] })
		}
		return ret.to_json()
	end
	def self.type_explanation(type_pos)
		return "Exhibits that have been shared but are not peer-reviewed." if type_pos == 0
		return "Student work that has been shared." if type_pos == 1
		return "Peer Reviewed work." if type_pos == 2
		return ""
	end

	def self.permissions()
		return [ 'hidden', 'readonly', 'full']
	end

	def self.friendly_permissions()
		return [ 'Private Discussion', 'Public Discussion', 'Open Discussion']
	end
	def self.permission_to_friendly(permissions)
		return self.friendly_permissions[0] if self.permissions()[0] == permissions
		return self.friendly_permissions[1] if self.permissions()[1] == permissions
		return self.friendly_permissions[2] if self.permissions()[2] == permissions
		return ""
	end
	def self.friendly_to_permission(permissions)
		return self.permissions[0] if self.friendly_permissions()[0] == permissions
		return self.permissions[1] if self.friendly_permissions()[1] == permissions
		return self.permissions[2] if self.friendly_permissions()[2] == permissions
		return ""
	end
	def self.permissions_to_json()
		vals = self.permissions()
		texts = self.friendly_permissions()
		ret = []
		0.upto(2) { |i|
			ret.push({ :value => vals[i], :text =>	texts[i] })
		}
		return ret.to_json()
	end
	def self.permission_explanations_to_json
		explanations = [ "Only group members may read and respond to private discussions.",
			"Anyone can read, but only group members may respond.",
			"Anyone can read and any #{SITE_NAME} user can respond."  ]
		return explanations.to_json()
	end

end
