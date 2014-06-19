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

module GroupsHelper
	def get_group_default_url(url)
		path = SKIN == 'modnets' ? "#{SKIN}/lg_site_image.gif" : "#{SKIN}/glossy_swirly.jpg"
    return image_path(path) if url == nil || url.length == 0
    return url
	end
	def get_group_image_url(group)
		return group.group_type == 'classroom' ? image_path("#{SKIN}/classroom_icon.sm.jpg") : get_group_default_url(get_url_for_internal_image(Image.find_by_id(group.image_id)))
	end

	def get_cluster_image_url(group, cluster)
		return image_path("#{SKIN}/classroom_icon.sm.jpg") if group.group_type == 'classroom'
		image_class = cluster.image ? cluster : group
		return get_group_default_url(get_url_for_internal_image(Image.find_by_id(image_class.image_id)))
	end

	def get_summary_header_class(obj)
		if obj.kind_of?(Exhibit)
			return ' group_only' if Group.get_exhibit_visibility(obj) != 'everyone'
		elsif obj.kind_of?(Cluster)
			return ' group_only' if obj.visibility != 'everyone'
		elsif obj.kind_of?(DiscussionThread)
			return ' group_only' if Group.get_discussion_visibility(obj) != 'everyone'
		end
		return ""
	end

	def get_summary_header_div(group, obj)
		html = ""
		if obj.kind_of?(Exhibit)
			return html if group == nil
			visibility = Group.get_exhibit_visibility(obj)
			if visibility == 'members'
				html += "<div class='group_only_text'>#{group.get_exhibits_label()} Shared to Group Only</div>"
			end
			if visibility == 'admin'
				html += "<div class='group_only_text'>#{group.get_exhibits_label()} Shared with Administrators Only</div>"
			end
		elsif obj.kind_of?(Cluster)
			if obj.visibility == 'members'
				html += "<div class='group_only_text'>#{group.get_clusters_label()} Shared to Group Only</div>"
			end
		elsif obj.kind_of?(DiscussionThread)
			if Group.get_discussion_visibility(obj) == 'members'
				html += "<div class='group_only_text'>Discussion Shared to Group Only</div>"
			end
		end
		return raw(html)
	end
end
