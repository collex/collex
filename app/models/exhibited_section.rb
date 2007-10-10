##########################################################################
# Copyright 2007 Applied Research in Patacriticism
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

class ExhibitedSection < ActiveRecord::Base
  # exhibited_texts and exhibited_resources are subclasses of exhibited_items
  has_many :exhibited_items, :order => "position", :dependent => :destroy
  alias_method :items, :exhibited_items
  
  has_many :exhibited_texts, :order => "position"
  alias_method :texts, :exhibited_texts
  has_many :exhibited_resources, :order => "position"
  alias_method :resources, :exhibited_resources
  
  belongs_to :exhibit_section_type
  belongs_to :exhibited_page
  alias_method :page, :exhibited_page
  acts_as_list :scope => :exhibited_page
  
  def template
    self.exhibit_section_type.template
  end
  
  def uris
    self.exhibited_resources.collect { |er| er.uri }
  end

  def title_message
    self.exhibit_section_type.title_message
  end
  
  def annotation_message
    self.exhibit_section_type.annotation_message
  end
  
end
