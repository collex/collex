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
end
