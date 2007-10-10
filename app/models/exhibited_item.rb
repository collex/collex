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

class ExhibitedItem < ActiveRecord::Base
  belongs_to :exhibited_section
  alias_method :section, :exhibited_section
  acts_as_list :scope => :exhibited_section
  
  attr_writer :title_message, :annotation_message
  def title_message
    @title_message || "(Insert Title)"
  end
  def annotation_message
    @annotation_message || "(Insert Annotation)"
  end

end
