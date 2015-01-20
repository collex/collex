##########################################################################
# Copyright 2011 Applied Research in Patacriticism and the University of Virginia
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

module BuilderHelper
  
  # Returns true if the currently logged in user can publish the
  # active exhibit as a different member
  #
  def can_publish_as_different_user?
    
    # only peer-reviewed groups can be published as a different user
    return false if @exhibit.group.nil?
    return false if  @exhibit.group.is_peer_reviewed() == false
    
    # general admins can do it
    return false if !user_signed_in?
    return true if is_admin?
    
    # so can group editors
    return true if @exhibit.group.is_editor(get_curr_user_id)
    
    return false
  end
end
