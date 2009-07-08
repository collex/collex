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
    return "<a class='nav_link' href='#{get_exhibit_url(exhibit)}'>#{h exhibit.title}</a>"
  end
  
  def get_exhibits_username(exhibit)
    user_id = exhibit.user_id
    user_id = exhibit.alias_id if exhibit.alias_id != nil && exhibit.alias_id > 0
    return User.find(user_id).fullname
  end
  
  def get_exhibits_user_institution(exhibit)
    user_id = exhibit.user_id
    user_id = exhibit.alias_id if exhibit.alias_id != nil && exhibit.alias_id > 0
    return User.find(user_id).institution
  end
  
  def get_exhibit_user_link(exhibit)
    user_id = exhibit.user_id
    user_id = exhibit.alias_id if exhibit.alias_id != nil && exhibit.alias_id > 0
    owner = User.find(user_id)
    get_user_link(owner)
  end
end
