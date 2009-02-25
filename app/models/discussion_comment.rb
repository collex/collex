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

class DiscussionComment < ActiveRecord::Base
  belongs_to :discussion_thread
  belongs_to :cached_resource
  belongs_to :exhibit
  acts_as_list :scope => :discussion_thread
  
  def before_save
    case comment_type
      when 'comment': comment_type = 1
      when 'nines_object': comment_type = 2
      when 'nines_exhibit': comment_type = 3
      when 'inet_object': comment_type = 4
    end
  end

  def get_type
    case comment_type
      when 1: return "comment"
      when 2: return "nines_object"
      when 3: return "nines_exhibit"
      when 4: return "inet_object"
      else return nil
    end
  end

end
