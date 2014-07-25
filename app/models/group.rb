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
	#TODO-PER: commented for Rails 3: has_and_belongs_to_many :users
  belongs_to :image#, :dependent=>:destroy
	after_save :handle_solr

	def handle_solr
		SearchUserContent.delay.index('group', self.id)
	end
	
	def is_peer_reviewed
	  return self.group_type == "peer-reviewed"
	end

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

	def self.get_discussion_visibility(thread)
		return 'everyone' if thread.group_id == nil
		group = Group.find_by_id(thread.group_id)
		return "" if group == nil
		return group.forum_permissions == 'hidden' ? 'members' : 'everyone'
	end

	def can_create_exhibit(user_id)
		return is_member(user_id)
	end

	def can_see_admins(user_id)
		return true if self.show_admins == 'all'
		return is_member(user_id)
	end

	def can_view_exhibits(user_id)
		return true if self.exhibit_visibility == 'www'
		return is_member(user_id)
	end

	def self.get_exhibit_visibility(exhibit)
		# if the exhibit isn't in a group, the only two levels should be 0 or 1. However, if the exhibit was removed from a group,
		# then the visibility may be more complicated. In that case, anything but 0 means published.
		if exhibit.group_id == nil
			return 'everyone' if exhibit.is_published != 0
			return 'noone'
		end
		return "admin" if exhibit.is_published == 4
		cluster = Cluster.find_by_id(exhibit.cluster_id)	# this can fail if the cluster was deleted with exhibits in it.
		return 'admin' if cluster && cluster.visibility == 'administrators'
		return 'admin' if exhibit.is_published == 2
		return 'members' if exhibit.editor_limit_visibility == 'group'
		return 'members' if exhibit.is_published == 3
		return 'everyone' # is_published must be either 1 (everyone) or 5 (submit for peer-review and everyone)
	end

	def can_view_exhibit(exhibit, user_id)
		# The exhibit is visible if the user is an admin of the group.
		# Then check to see if it is in a restricted cluster, or it is a restricted exhibit. If so, then it is not visible.
		# Then see if the user is a member. If so, then it is visible.
		# Then see if it is restricted to the group.
		
		# see if only an editor can see it.
		return true if is_editor(user_id)
		return false if exhibit.is_published == 4
		cluster = Cluster.find_by_id(exhibit.cluster_id)	# this can fail if the cluster was deleted with exhibits in it.
		return false if cluster && cluster.visibility != 'everyone'

		# see if only a member can see it
		return true if is_member(user_id)
		return true if (exhibit.is_published == 1 || exhibit.is_published == 5) && (exhibit.editor_limit_visibility == nil || exhibit.editor_limit_visibility != 'group')
		return false
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
	
	def non_clustered_exhibits()
		ret = []
		exhibits = Exhibit.all(:conditions => [ "group_id = ? AND is_published <> 0 AND cluster_id IS NULL", self.id])
		exhibits.each { |exhibit|
			if exhibit.cluster_id == nil
				ret.push({ :text => exhibit.title, :value => exhibit.id })
			end
		}
		return ret
	end
	
	def get_all_editors()
		gus = GroupsUser.where({group_id: self.id, role: 'editor'})
		editors = []
		editors.push(self.owner)
		gus.each { |gu|
			editors.push(gu.user_id)
		}
		return editors
	end

	def self.get_all_users_groups(user_id)
		groups = Group.where({owner: user_id})
		gu = GroupsUser.where({user_id: user_id})
		gu.each { |rec|
			if !rec.pending_invite & !rec.pending_request
				groups.push(Group.find(rec.group_id))
			end
		}
		return groups
	end

	def self.get_all_users_admins(groups, user_id)
		admin_groups = []
		groups.each {|group|
			admin_groups.push(group) if group.is_editor(user_id)
		}
		return admin_groups
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

	def get_membership_list(with_owner = false)
		gus = GroupsUser.where({group_id: self.id})
		ret = []
		gus.each { |gu|
			if gu.pending_invite == false && gu.pending_request == false
				user = User.find(gu.user_id)
				ret.push({ :name => user.fullname, :user_id => user.id, :id => gu.id, :role => gu.role })
			end
		}
		if with_owner
			ret.push({ :name => self.user.fullname, :user_id => self.user.id, :id => nil, :role => 'owner' })
		end
		return ret
	end

	def get_membership_list_truncated(max)
		mems = get_membership_list()
		return mems if mems.length <= max

		mems = mems.sort_by { rand }
		return mems.slice(0, max)
	end

	def get_number_of_members()
		list = get_membership_list()
		return list.length + 1 # the regular members plus the owner
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

	def invite_members(editor_name, editor_email, emails, usernames, url_accept, url_decline, url_home)
		msgs = ""
		list = []
		arr = split_by_all_delimiters(usernames)
		arr.each { |username|
			username = username.strip()
			if username.length > 0
				user = User.find_by_username(username)
				if user == nil
					msgs += "User not found: #{username}<br />"
				else
					list.push(user.email)
				end
			end
		}

		arr = split_by_all_delimiters(emails)
		arr.each { |email|
			# The user may have put in lots of different email formats, or may have put in unintelligible data. We will only
			# keep emails that appear to be well-formed.
			email = email.strip()
			is_legal = /^\<?.+@.+\..+\>?$/.match(email) # emails must be in the form: aaa@aaa.aaa, possibly bracketed by <...>
			if email.length > 0 && is_legal != nil
				email = email.gsub("<", '').gsub(">", '')   # don't want the bracketing
				list.push(email)
			end
		}

		list.each { |email|
			gu = GroupsUser.find_by_group_id_and_email(self.id, email)
			user = User.find_by_email(email)
			user_id = user ? user.id : nil
			user_name = user ? user.fullname : ""
			if gu == nil && self.owner != user_id	# don't invite someone twice
				begin
					gu = GroupsUser.new({ :group_id => self.id, :user_id => user_id, :email => email, :role => 'member', :pending_invite => true, :pending_request => false })
					gu.save!
					body = "#{editor_name} has invited you to join the group \"#{self.name}.\"\n\n"
					if user_id == nil
						body += "To join this group, you will be prompted to create a login ID on #{Setup.site_name()}.\n\n"
					end
					accept = url_accept.gsub("PUT_ID_HERE", "#{Group.id_obfuscator(gu.id)}")
					decline = url_decline.gsub("PUT_ID_HERE", "#{Group.id_obfuscator(gu.id)}")
					body += "If you wish to join this group, click here: #{accept}\n\n"
					body += "If you do not wish to join this group, click here: #{decline}\n\n"
					GenericMailer.generic(editor_name, editor_email, user_name, email, 
					   "Invitation to join a group", body, url_home, "").deliver
				rescue Net::SMTPFatalError
					msgs += "Error sending email to address \"#{email}\".<br />"
					gu.delete
				end
			end
		}
		return nil if msgs.length == 0
		return msgs
	end

	def get_visible_id
		return self.visible_url if self.visible_url && self.visible_url.length > 0
		return "#{self.id}"
	end

	def get_visible_url
		return "/groups/#{get_visible_id()}"
	end

	def get_exhibits_label()
		return 'Exhibit' if self.exhibits_label == nil
		return self.exhibits_label
	end

	def get_clusters_label()
		return 'Cluster' if self.clusters_label == nil
		return self.clusters_label
	end

	def self.get_exhibits_label(group_id)
		return 'Exhibit' if group_id == nil
		group = Group.find_by_id(group_id)
		return 'Exhibit' if group == nil
		return group.get_exhibits_label()
	end

	def self.get_clusters_label(group_id)
		return 'Cluster' if group_id == nil
		group = Group.find_by_id(group_id)
		return 'Cluster' if group == nil
		return group.get_clusters_label()
	end

	def get_truncated_name()
		return self.name if self.name.length < 70
		return self.name.slice(0..70) + "..."
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
			"Anyone can read and any #{Setup.site_name()} user can respond."  ]
		return explanations.to_json()
	end

	def self.visibility()
		return [ 'group', 'www' ]
	end

	def self.friendly_visibility()
		return [ 'Visible to Group', 'Visible to WWW']
	end
	def self.visibility_to_friendly(visibility)
		return self.friendly_visibility[0] if self.visibility()[0] == visibility
		return self.friendly_visibility[1] if self.visibility()[1] == visibility
		return ""
	end
	def self.friendly_to_visibility(visibility)
		return self.visibility[0] if self.friendly_visibility()[0] == visibility
		return self.visibility[1] if self.friendly_visibility()[1] == visibility
		return ""
	end
	def self.visibility_to_json()
		vals = self.visibility()
		texts = self.friendly_visibility()
		ret = []
		0.upto(1) { |i|
			ret.push({ :value => vals[i], :text =>	texts[i] })
		}
		return ret.to_json()
	end
	def self.visibility_explanations_to_json
		explanations = [ "Only group members may view exhibits.",
			"Anyone can view exhibits." ]
		return explanations.to_json()
	end

	def self.show_exhibits()
		return [ 'show_all', 'show_clusters_only', 'show_exhibits_only']
	end

	def self.friendly_show_exhibits()
		return [ 'Show all', 'Show clusters only', 'Show exhibits only' ]
	end
	def self.show_exhibits_to_friendly(show_exhibits)
		return self.friendly_show_exhibits[0] if self.show_exhibits()[0] == show_exhibits
		return self.friendly_show_exhibits[1] if self.show_exhibits()[1] == show_exhibits
		return self.friendly_show_exhibits[2] if self.show_exhibits()[2] == show_exhibits
		return ""
	end
	def self.friendly_to_show_exhibits(permissions)
		return self.show_exhibits[0] if self.friendly_show_exhibits()[0] == permissions
		return self.show_exhibits[1] if self.friendly_show_exhibits()[1] == permissions
		return self.show_exhibits[2] if self.friendly_show_exhibits()[2] == permissions
		return ""
	end
	
	def show_exhibits_to_json()
		vals = Group.show_exhibits()
		texts = Group.friendly_show_exhibits()
		exhibit_label = get_exhibits_label().pluralize().downcase()
		clusters_label = get_clusters_label().pluralize().downcase()
		texts.each do | txt |
   		txt.gsub!("clusters", clusters_label)
         txt.gsub!("exhibits", exhibit_label)   
		end
		
		ret = []
		0.upto(2) { |i|
			ret.push({ :value => vals[i], :text =>	texts[i] })
		}
		return ret.to_json()
	end
	
	def show_exhibits_explanations_to_json
		explanations = [ "List both #{get_clusters_label().pluralize().downcase()} and #{get_exhibits_label().pluralize().downcase()} in the #{get_exhibits_label().pluralize().downcase()} list.",
			"List only #{get_clusters_label().pluralize().downcase()} and #{get_exhibits_label().pluralize().downcase()} that belong to #{get_clusters_label().pluralize().downcase()} in the #{get_exhibits_label().pluralize().downcase()} list.",
			"List only #{get_exhibits_label().pluralize().downcase()} and not #{get_clusters_label().pluralize().downcase()} in the #{get_exhibits_label().pluralize().downcase()} list."  ]
		return explanations.to_json()
	end

	def get_exhibit_label_list
		return [ { :value => 'Exhibit', :text => 'Exhibit'}, { :value => 'Article', :text => 'Article' }]
	end

	def get_cluster_label_list
		return [ { :value => 'Cluster', :text => 'Cluster'}, { :value => 'Issue', :text => 'Issue' }, { :value => 'Volume', :text => 'Volume' }]
	end
end
