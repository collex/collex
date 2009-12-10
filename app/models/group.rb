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
		return group.license_type == nil
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
		groups += User.find(user_id).groups
		return groups
	end

	def get_pending_id(user_id)
		user = User.find(user_id)
		gu = GroupsUser.find_by_group_id_and_email(self.id, user.email)
		return Group.id_obfuscator(gu.id) if gu != nil && gu.pending_invite == true
		return nil
	end

	def is_request_pending(user_id)
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
				ret.push({ :name => User.find(gu.user_id).fullname, :id => gu.id, :role => gu.role })
			end
		}
		return ret
	end

	#
	# Actions
	#
	def invite_members(emails)
		arr = emails.split("\n")
		arr.each { |email|
			email = email.strip()
			if email.length > 0
				user = COLLEX_MANAGER.find_by_email(email)
				if (user == nil)	# inviting a user who doesn't have a login
					user_id = nil
				else
					user_id = user.id
				end

				gu = GroupsUser.find_by_group_id_and_email(self.id, email)
				if gu == nil	# don't invite someone twice
					gu = GroupsUser.new({ :group_id => self.id, :user_id => user_id, :email => email, :role => 'member', :pending_invite => true, :pending_request => false })
					gu.save!
					LoginMailer.deliver_invite_member_to_group({ :group_name => self.name, :request_id => gu.id, :has_joined => user_id != nil }, email)
				end
			end
		}
	end

	#
	# enumerations
	#
	def self.types()
		return [ 'community', 'classroom']
	end

	def self.friendly_types()
		return [ 'Community', 'Classroom']
	end
	def self.type_to_friendly(type)
		return self.friendly_types[0] if self.types()[0] == type
		return self.friendly_types[1] if self.types()[1] == type
		return ""
	end
	def self.friendly_to_type(type)
		return self.types[0] if self.friendly_types()[0] == type
		return self.types[1] if self.friendly_types()[1] == type
		return ""
	end
	def self.types_to_json()
		vals = self.types()
		texts = self.friendly_types()
		ret = []
		0.upto(1) { |i|
			ret.push({ :value => vals[i], :text =>	texts[i] })
		}
		return ret.to_json()
	end
	def self.type_explanation(type_pos)
		return "Exhibits that have been shared but are not peer-reviewed." if type_pos == 0
		return "Student work that has been shared." if type_pos == 1
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

end
