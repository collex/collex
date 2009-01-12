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

class Exhibit < ActiveRecord::Base
  has_many :exhibit_pages, :order => :position, :dependent=>:destroy
  has_many :exhibit_objects, :dependent=>:destroy
  
  def self.factory(user_id)
    exhibit = Exhibit.create(:title =>'Untitled', :user_id => user_id)
    exhibit.insert_page(1)
    return exhibit
  end
  
  def insert_page(page_num)
    new_page = ExhibitPage.create(:exhibit_id => id)
    new_page.insert_at(page_num)
    new_page.insert_element(1)
  end
  
  def move_page_up(page_num)
    curr_page = exhibit_pages[page_num-1]
    curr_page.move_higher()
  end
  
  def move_page_down(page_num)
    curr_page = exhibit_pages[page_num-1]
    curr_page.move_lower()
  end
  
  def delete_page(page_num)
    curr_page = exhibit_pages[page_num-1]
    curr_page.remove_from_list()
    curr_page.destroy
  end
  
  def self.find_by_illustration_id(illustration_id)
    illustration = ExhibitIllustration.find(illustration_id)
    return self.find_by_element_id(illustration.exhibit_element_id)
  end
  
  def self.find_by_element_id(element_id)
    element = ExhibitElement.find(element_id)
    page = ExhibitPage.find(element.exhibit_page_id)
    return Exhibit.find(page.exhibit_id)
  end
  
  def self.js_array_of_all_my_exhibits(user_id)
    my_exhibits = find(:all, :conditions => ['user_id = ?', user_id] )
    return "" if my_exhibits.length == 0
    
    str = ""
    for exhibit in my_exhibits
      if str != ""
        str += ","
      end
      str += '"' + h(exhibit.title) + '"'
      #str += '"' + exhibit.title.gsub('"', "\\\"") + '"'
    end
    return str
  end

#  def self.find_by_section_id(section_id)
#    section = ExhibitSection.find(section_id)
#    page = ExhibitPage.find(section.exhibit_page_id)
#    return Exhibit.find(page.exhibit_id)
#  end
end
