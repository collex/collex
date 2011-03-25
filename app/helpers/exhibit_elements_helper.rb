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

module ExhibitElementsHelper
  def get_exhibit_id(exhibit)
    return exhibit.visible_url && exhibit.visible_url.length > 0 ? exhibit.visible_url : exhibit.id
  end
  
  def get_exhibit_url(exhibit)
    return "/exhibits/#{get_exhibit_id(exhibit)}"
  end
  
  def get_exhibit_link(exhibit)
    return raw("<a class='nav_link' href='#{get_exhibit_url(exhibit)}'>#{exhibit.title}</a>")
  end

	def get_cluster_link(cluster_id)
		return nil if cluster_id == nil
		cluster = Cluster.find_by_id(cluster_id)
		return nil if cluster == nil
		return link_to(cluster.get_truncated_name(), cluster.get_visible_url(), { :class => 'nav_link' })
	end

  def get_exhibits_username(exhibit)
    user = exhibit.get_apparent_author()
    return user.fullname
  end
  
  def get_exhibits_username_list(exhibit, is_edit_mode)
    users = exhibit.get_authors()
	names = ""
	users.each {|user|
		del_link = ''
		if names.length > 0
			if user.id == users.last.id
				names += ' and '
			else
				names += ', '
			end
			del_link = link_to_function("[X]", "serverAction({action: { actions: '/builder/remove_additional_author', els: 'exhibit_page', params: { exhibit_id: #{exhibit.id}, user_id: #{user.id}} }, progress: { waitMessage: 'Removing Author...' })", :class => 'nav_link')
		end
		names += user.fullname
		if names.length > 0 && is_edit_mode
			names += del_link
		end
	}
    return raw(names)
  end

	def get_exhibits_user_institution(exhibit)
		users = exhibit.get_authors()
		return "" if users.length > 1
		user = exhibit.get_apparent_author()
		return user.institution ? user.institution : ''
	end
  
  def get_exhibit_user_link(exhibit)
    users = exhibit.get_authors()
	names = ""
	users.each {|user|
		if names.length > 0
			if user.id == users.last.id
				names += ' and '
			else
				names += ', '
			end
		end
		names += get_user_link(user)
	}
    return raw(names)
  end

	def draw_footnote(footnote_id, parent_id, is_edit_mode)
		if footnote_id
			click = is_edit_mode ? "" : "var footnote = $(this).next(); new MessageBoxDlg(\"Footnote\", footnote.innerHTML); "
			html = "<a href='#' onclick='#{click}return false;' class='superscript'>@</a>\n"
			html += "<span id='footnote_for_#{parent_id}' class='hidden'>#{is_edit_mode ? ExhibitFootnote.find(footnote_id).footnote : decode_exhibit_links(ExhibitFootnote.find(footnote_id).footnote)} </span>\n"
			return raw(html)
		end
		return ""
	end
end
