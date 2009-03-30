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
  
  def get_user_link(user)
    if user.class == Fixnum
      user = User.find(user)
    end
    if user.link != nil && user.link != ""
      link_to(user.fullname, user.link, :class => 'ext_link', :target => '_blank')
    else
      user.fullname
    end
  end
  
  def make_ext_link(url)
    str = h(url)
    if url.index("http") != 0  # if the link doesn't start ith http, then we'll add it.
      url = "http://" + url
    end
    return "<a class='ext_link' target='_blank' href='#{url}'>#{str}</a>"
  end
  
  def get_user_picture(user_id, type)
    placeholder = "/images/person_placeholder.jpg"
    user = User.find_by_id(user_id)
    return placeholder if user == nil
    return placeholder if user.image == nil
    return placeholder if user.image.public_filename == nil

    full_size_path = user.image.public_filename
    file_path = user.image.public_filename(type)
  
    if File.exists?("#{RAILS_ROOT}/public/#{file_path}")
      return file_path
    elsif File.exists?("#{RAILS_ROOT}/public/#{full_size_path}")
      return full_size_path
    else
      return placeholder
    end
  end
end
