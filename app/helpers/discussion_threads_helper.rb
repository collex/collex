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

module DiscussionThreadsHelper
  def toggle_discussion_topic( topic_num, item_id_prefix, toggle_function, initial_state )
    display_none = 'style="display:none"'
    label = ""
    
    label << "<span id=\"#{item_id_prefix}_#{topic_num}_closed\" #{initial_state == :open ? display_none : ''} >"
    label << link_to_function(closed_char(),"#{toggle_function}('#{item_id_prefix}_#{topic_num}')", { :class => 'modify_link' })
    label << "</span>\n"
    label << "<span id=\"#{item_id_prefix}_#{topic_num}_opened\" #{initial_state == :closed ? display_none : ''} >"
    label << link_to_function(opened_char(), "#{toggle_function}('#{item_id_prefix}_#{topic_num}')", { :class => 'modify_link'})
    label << "</span>\n"
    return label
  end

  def get_user_info_url(user)
	  return "/my_collex/show_profile?user=#{user.id}"
  end

  def get_user_link(user)
    if user.class == Fixnum
      user = User.find_by_id(user)
	end
	if user
	    link_to_function(user.fullname, "showPartialInLightBox('#{get_user_info_url(user)}', 'Profile for #{user.fullname}', '#{image_path(PROGRESS_SPINNER_PATH)}')", :class => 'nav_link')
	else
		"Unknown"
	end
  end

  def get_user_link_with_thumbnail(user, height)
    if user.class == Fixnum
      user = User.find_by_id(user)
    end
		img = "<img height=\"#{height}\" title=\"#{user.fullname}\" alt=\"#{user.fullname}\" src=\"#{get_user_picture(user.id, :micro)}\"/>"
		link_to_function(raw(img), "showPartialInLightBox('#{get_user_info_url(user)}', 'Profile for #{user.fullname}', '#{image_path(PROGRESS_SPINNER_PATH)}')", :class => 'nav_link')
  end

  def make_ext_link(url)
    str = h(url)
    if url.index("http") != 0  # if the link doesn't start with http, then we'll add it.
      url = "http://" + url
    end
    return raw("<a class='ext_link' target='_blank' href='#{url}'>#{str}</a>")
  end
  
  def make_edit_link(comment, is_main, can_delete)
    html = "<a href='#' class='nav_link' onclick=\"new ForumReplyDlg({" +
      "comment_id: #{comment.id},"
    if is_main # only the main comment has a title.
			thread = DiscussionThread.find(comment.discussion_thread_id)
      html += "title: '#{thread.get_title()}'," +
      "license: #{thread.license ? thread.license : 1},"
    end
    html += "obj_type: #{comment.comment_type}," +
      "reply: 'comment_body_#{comment.id}'," +
      "nines_obj_list: '#{comment.cached_resource_id && comment.cached_resource_id > 0 ? CachedResource.find(comment.cached_resource_id).uri : ''}'," +
      "exhibit_list: 'id_#{comment.exhibit_id}'," +
			"can_delete: #{can_delete ? 'true' : 'false'}," +
      "inet_thumbnail: '#{comment.image_url}'," +
      "inet_title: '#{comment.link_title}'," +
      "inet_url: '#{comment.link_url}'," +
      "ajax_div: 'comment_id_#{comment.id}'," +
      "submit_url: '/forum/edit_existing_comment'," +
      "populate_exhibit_url: '/forum/get_exhibit_list'," +
      "populate_collex_obj_url: '/forum/get_nines_obj_list'," +
      "progress_img: '#{image_path(PROGRESS_SPINNER_PATH)}'," +
      "logged_in: true }); return false;\">[edit]</a>"
    return raw(html)
  end
  
  def get_user_picture(user_id, type)
    placeholder = image_path(GENERIC_USER_IMAGE_PATH)
    user = User.find_by_id(user_id)
    return placeholder if user == nil
    return placeholder if user.image_id == nil
	image = Image.find_by_id(user.image_id)
    return placeholder if image == nil || image.photo_file_name == nil

    full_size_path = image.photo.url.split('?')[0]
    file_path = image.photo.url(type).split('?')[0]
  
    if File.exists?("#{Rails.root}/public/#{file_path}")
      return "/#{file_path}"
    elsif File.exists?("#{Rails.root}/public/#{full_size_path}")
      return "/#{full_size_path}"
    else
      return placeholder
    end
  end
  
  def is_new_post(tim)
    return tim > (Time.now - 86400*1)
  end
  
  def comment_time_format(tim)
	  return "NONE" if tim == nil
    return tim.getlocal().strftime("%b %d, %Y %I:%M%p")
  end

  def comment_time_format_relative(tim)
		if tim > 28.days.ago
	    return time_ago_in_words(tim) + " ago"
		else
			return comment_time_format(tim)
		end
  end

  def sort_topics(by_date, topics)
    if by_date
      topics = topics.sort {|a,b| 
        if b[:date] && a[:date] # if there are posts in both items, then compare the dates.
          b[:date] <=> a[:date]
        elsif !b[:date] && !a[:date]  # if there are posts in neither item, then compare alpha
          a[:topic_rec].topic <=> b[:topic_rec].topic
        elsif a[:date]  # if there are posts in only one item, then that item is sorted first
          -1
        else
          1
        end
      }
    else
      topics = topics.sort {|a,b| a[:topic_rec].topic <=> b[:topic_rec].topic }
    end
    return topics
  end
  
  def get_comment_header_info(comment)
    title = DiscussionThread.find(comment.discussion_thread_id).get_title()
    if comment.get_type() == "comment"
      thumbnail = nil #get_user_picture(comment.user_id, :thumb)
      link = nil
      caption = nil
    elsif comment.get_type() == "nines_object"
      hit = CachedResource.get_hit_from_resource_id(comment.cached_resource_id)
      thumbnail = get_image_url(CachedResource.get_thumbnail_from_hit_no_site(hit))
      link = hit["url"] ? hit["url"] : nil
      caption = hit['title'] ? hit['title'] : ""
    elsif comment.get_type() == "nines_exhibit"
      exhibit = Exhibit.find(comment.exhibit_id)
      thumbnail = exhibit.thumbnail == "You have not added a thumbnail to this exhibit." ? nil : exhibit.thumbnail
      link = get_exhibit_url(exhibit)
      caption = exhibit.title
    elsif comment.get_type() == "inet_object"
      thumbnail = comment.image_url
      link = comment.link_url
      caption = comment.link_title != nil && comment.link_title.length > 0 ? comment.link_title : comment.link_url
    else
      title = "ERROR: ill-formed comment. (Comment type #{ comment.comment_type } is unknown)"
      thumbnail = nil
      link = nil
      caption = nil
    end
		thumbnail = nil if thumbnail != nil && thumbnail.length == 0
    thread = DiscussionThread.find(comment.discussion_thread_id)
		group_comment = ""
		if thread.group_id != nil && thread.group_id > 0
			group = Group.find(thread.group_id)
			group_link = link_to(group.name, { :controller => 'groups', :action => 'show', :id => group.id }, {:class => 'nav_link'} )
			group_comment = case group.forum_permissions
				when 'hidden' then "A private discussion for members of #{group_link}. Only members can read and comment."
				when 'readonly' then "A public discussion featuring members of #{group_link}. Only members may comment."
				when 'full' then "An open discussion sponsored by #{group_link}. All #{Setup.site_name()} users can read and comment."
				else ''
			end
			if user_signed_in?
				readonly = user_can_reply(comment) == false
				if readonly
					group_comment += "<br />This thread is read only."
				end
			else
				if group.forum_permissions == 'full'
					group_comment += "<br />#{sign_in_link({ :class => 'nav_link', :text => 'Log in' })} or #{sign_up_link({ :class => 'nav_link', :text => 'create an account' })} to participate."
				end
			end
		end
    last_comment = thread.discussion_comments[thread.discussion_comments.length-1]
    return { :title => title, :thumbnail => thumbnail, :author => User.find(comment.user_id), :link => link, :caption => caption,
      :last_comment_author => User.find(last_comment.user_id), :last_comment_time => last_comment.updated_at,
			:group_comment => raw(group_comment) }
  end

	def user_can_reply(comment)
		thread = DiscussionThread.find(comment.discussion_thread_id)
		return true if thread.group_id == nil || thread.group_id <= 0
		group = Group.find(thread.group_id)
		return current_user ? group.can_post(get_curr_user_id) : false
	end

  def forum_title_with_tooltip(title, comment)
    comment = strip_tags(comment) if comment != nil
    abbrev_comment = ""
    abbrev_comment = comment.slice(0,100) if comment != nil
    abbrev_comment += '...' if abbrev_comment != comment
    abbrev_title = title.slice(0,60)
    abbrev_title = abbrev_title + "..." if title.length > 60
		# Note: apparently, you can't put any div's in this because Safari will get confused.
    return raw("#{abbrev_title}<span class='discussion_title_tooltip'><b class='discussion_title_tooltip_title'>#{title}</b><br/><br/>#{abbrev_comment}</span>")
  end
end
