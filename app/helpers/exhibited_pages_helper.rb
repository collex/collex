##########################################################################
# Copyright 2007 Applied Research in Patacriticism and the University of Virginia
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

module ExhibitedPagesHelper
  def exhibited_pages_links(exhibited_page, edit = false)
    exhibit = exhibited_page.exhibit
    position = exhibited_page.position
    index = position - 1
    max_index = exhibit.pages.size - 1
    
    route_method = edit ? :edit_page_path : :page_path
    links = ""
    links << link_to("|&larr;first&nbsp;", __send__(route_method, exhibit, exhibit.pages.first)) unless index < 1
    links << link_to("&nbsp;&#x21E0;&nbsp;prev&nbsp;", __send__(route_method, exhibit, exhibit.pages[index - 1])) + "&nbsp;" unless index < 1
    links << "page #{position} of #{exhibit.pages.size}"
    links << "&nbsp;" + link_to("&nbsp;next&nbsp;&#x21E2;&nbsp;", __send__(route_method, exhibit, exhibit.pages[index + 1])) unless index >= max_index
#     links << "&nbsp;" + link_to(exhibit.pages.size, __send__(route_method, exhibit, exhibit.pages[-1])) unless index >= max_index
    links << link_to("&nbsp;last&rarr;|", __send__(route_method, exhibit, exhibit.pages[-1])) unless index >= max_index
    links
  end
end
