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

class ExhibitElement < ActiveRecord::Base
  belongs_to :exhibit_page
  acts_as_list :scope => :exhibit_page
  
  has_many :exhibit_illustrations, :order => :position, :dependent=>:destroy
  
  def self.factory(page)
    return ExhibitElement.create(:exhibit_page_id => page, :border_type_enum => 0, :exhibit_element_layout_type => 'text', :element_text => "<span style=\"font-family: Times New Roman;\">Enter Your Text Here</span>")
  end
  
  def get_border_type
    case border_type_enum
      when 0: return "no_border"
      when 1: return "start_border"
      when 2: return "continue_border"
    end
  end
  
  def set_border_type(border_type)
    case border_type
      when "no_border": self.border_type_enum = 0
      when "start_border": self.border_type_enum = 1
      when "continue_border": self.border_type_enum = 2
    end
    save()
  end
  
  def change_layout(new_layout)
        self.exhibit_element_layout_type = new_layout
        save()
  end
  
  def copy_data_portion(src_element)
    # This copies everything except the control fields (that is, position, id, and the exhibit_page_id)
    self.exhibit_element_layout_type = src_element.exhibit_element_layout_type
    self.element_text = src_element.element_text
    self.border_type_enum = src_element.border_type_enum
    save()
    illustrations = src_element.exhibit_illustrations
    illustrations.each { |illustration|
      illustration.exhibit_element_id = id
      illustration.save()
    }
  end
end
