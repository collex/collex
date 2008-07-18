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

class Interpretation < ActiveRecord::Base
  validates_uniqueness_of :object_uri, :scope => :user_id
  
  belongs_to :user
  has_many :taggings, :dependent => :destroy
  has_many :tags, :through => :taggings
  
  def tag_list
    tags.map { |t| t.name }.join(" ")
  end
  
  def tag_list=(tag_string)
    Tagging.set_on(self, tag_string)
    taggings.reset
    tags.reset
  end
    
  def add_tag(tag_string)
    Tagging.add_to(self, Tag.parse_to_tag(tag_string) )
  end
  
  def remove_tag(tag_string)
    Tagging.delete_from(self, Tag.parse_to_tag(tag_string) )
  end
  
end
