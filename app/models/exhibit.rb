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
    exhibit = Exhibit.create(:title =>'Untitled', :user_id => user_id, :thumbnail => '', :visible_url => '', :is_published => 0)
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
  
  def self.js_array_of_all_public_exhibits()
    exhibits = self.get_all_published()
    str = ""
    for exhibit in exhibits
      if str != ""
        str += ",\n"
      end
      str += "{ title: \"#{h(exhibit.title)}\", thumbnail: \"#{exhibit.thumbnail}\" }";
    end
    return str
  end

  def self.get_sharing_text(s)
    case s
      when nil: return ""
      when 0: return ""
      when 1: return "This license lets others distribute, remix, tweak, and build upon your work, even commercially, as long as they credit you for the original creation. This is the most accommodating of licenses offered, in terms of what others can do with your works licensed under Attribution."
      when 2: return "This license lets others remix, tweak, and build upon your work even for commercial reasons, as long as they credit you and license their new creations under the identical terms. This license is often compared to open source software licenses. All new works based on yours will carry the same license, so any derivatives will also allow commercial use."
      when 3: return "This license allows for redistribution, commercial and non-commercial, as long as it is passed along unchanged and in whole, with credit to you."
      when 4: return "This license lets others remix, tweak, and build upon your work non-commercially, and although their new works must also acknowledge you and be non-commercial, they don’t have to license their derivative works on the same terms."
      when 5: return "This license lets others remix, tweak, and build upon your work non-commercially, as long as they credit you and license their new creations under the identical terms. Others can download and redistribute your work just like the by-nc-nd license, but they can also translate, make remixes, and produce new stories based on your work. All new work based on yours will carry the same license, so any derivatives will also be non-commercial in nature."
      when 6: return "This license is the most restrictive of our six main licenses, allowing redistribution. This license is often called the “free advertising” license because it allows others to download your works and share them with others as long as they mention you and link back to you, but they can’t change them in any way or use them commercially."
      else return ""
    end
  end

  def published?()
    return is_published != nil && is_published != 0
  end
  
  def get_sharing()
    return Exhibit.get_sharing_static(is_published)
  end
  
  def get_sharing_int()
    return is_published == nil ? 0 : is_published
  end
  
  def self.get_sharing_static(s)
    case s
      when nil: return "Not Shared"
      when 0: return "Not Shared"
      when 1: return "Attribution"
      when 2: return "Attribution Share Alike"
      when 3: return "Attribution No Derivatives"
      when 4: return "Attribution Non-Commercial"
      when 5: return "Attribution Non-Commercial Share Alike"
      when 6: return "Attribution Non-Commercial No Derivatives"
      else return "Not Shared"
    end
  end
  
  def set_sharing(str)
    case str
      when "Not Shared": self.is_published = 0
      when "Attribution": self.is_published = 1
      when "Attribution Share Alike": self.is_published = 2
      when "Attribution No Derivatives": self.is_published = 3
      when "Attribution Non-Commercial": self.is_published = 4
      when "Attribution Non-Commercial Share Alike": self.is_published = 5
      when "Attribution Non-Commercial No Derivatives": self.is_published = 6
      when '0': self.is_published = 0
      when '1': self.is_published = 1
      when '2': self.is_published = 2
      when '3': self.is_published = 3
      when '4': self.is_published = 4
      when '5': self.is_published = 5
      when '6': self.is_published = 6
      else self.is_published = 0
    end
  end

  def self.get_sharing_license_type(is_published)
    case is_published
      when 1: return "by"
      when 2: return "by-sa"
      when 3: return "by-nd"
      when 4: return "by-nc"
      when 5: return "by-nc-sa"
      when 6: return "by-nc-nd"
      else return "ERROR"
    end
  end

  def get_sharing_widget()
    if published?
      license = Exhibit.get_sharing_license_type(is_published)
      return "#{get_sharing_icon_with_link()}<p>This work is licensed under a <a rel=\"license\" target='_blank' href=\"http://creativecommons.org/licenses/" +
        license + "/3.0/us/\">Creative Commons " + get_sharing() + " 3.0 United States License</a>.</p>"
    else
      return "This exhibit is visible to just me."
    end
  end
  
  def get_sharing_image()
    return Exhibit.get_sharing_icon_url(is_published)
  end
  
  def self.get_sharing_icon_url(is_published)
    if is_published != nil && is_published != 0
      return "<img alt='Creative Commons License' style='border-width:0' src='http://i.creativecommons.org/l/#{get_sharing_license_type(is_published)}/3.0/us/88x31.png' />"
    else
      return "<img alt='Creative Commons License' height='31' style='border-width:0' src='/images/not_shared.jpg' />"
    end
  end
  
  def get_sharing_icon_with_link()
    license = Exhibit.get_sharing_license_type(is_published)
    return "<a rel=\"license\" target='_blank' href=\"http://creativecommons.org/licenses/" +
      license + "/3.0/us/\">#{Exhibit.get_sharing_icon_url(is_published)}</a>"
  end
  
  def self.get_all_published
    return Exhibit.find(:all, :conditions => [ 'is_published <> 0'])
  end
  
  def self.getJsonLicenseInfo()
    str = "[ { text: 'Exhibit should be visible to just me', icon: \"#{self.get_sharing_icon_url(0)}\" },"
    1.upto(6) do |i|
      str = str + "{ text: '" + self.get_sharing_text(i) + "', icon: \"" + self.get_sharing_icon_url(i) + "\" }"
#      str = str + "{ text: '" + "t" + "', icon: \"" + "i" + "\" }"
      str = str + "," if i != 6
    end
    str = str + "]"
    return str
  end
  
  def get_id_if_no_visible_url()
    if visible_url == nil || visible_url.length == 0
      return "#{id}"
    end
    return ''
  end

#  def self.find_by_section_id(section_id)
#    section = ExhibitSection.find(section_id)
#    page = ExhibitPage.find(section.exhibit_page_id)
#    return Exhibit.find(page.exhibit_id)
#  end
end
