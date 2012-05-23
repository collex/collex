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

  after_save :handle_solr

  def handle_solr
	  SearchUserContent.delay.index('exhibit', self.exhibit_page.exhibit.id)
  end

  def self.factory(page)
    return ExhibitElement.create(:exhibit_page_id => page, :border_type_enum => 0, :exhibit_element_layout_type => 'text', :element_text2 => "Enter your text here.", :element_text => "Enter your text here.")
  end

	def set_header_footnote(footnote_str)
		if footnote_str != nil && footnote_str.length > 0
			if self.header_footnote_id == nil	# if there didn't used to be a footnote, but there is now
				footnote_rec = ExhibitFootnote.create({ :footnote => footnote_str })
				self.header_footnote_id = footnote_rec.id
			else # if there was a footnote and there still is
				footnote_rec = ExhibitFootnote.find(self.header_footnote_id)
				footnote_rec.update_attributes({ :footnote => footnote_str })
			end
		else	# There is no footnote specified.
			if self.header_footnote_id != nil	# there used to be a footnote
				footnote_rec = ExhibitFootnote.find(self.header_footnote_id)
				footnote_rec.destroy()
				self.header_footnote_id = nil
			end
		end
	end

  def get_border_type
    case border_type_enum
      when 0 then return "no_border"
      when 1 then return "start_border"
      when 2 then return "continue_border"
    end
  end
  
  def set_border_type(border_type)
    case border_type
      when "no_border" then self.border_type_enum = 0
      when "start_border" then self.border_type_enum = 1
      when "continue_border" then self.border_type_enum = 2
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
  
  def get_justification
    case justify
      when 0 then return "left"
      when 1 then return "center"
      when 2 then return "right"
      else return "left"
    end
  end
  
  def set_justification(j)
    case j
      when "left"  then self.justify = 0
      when "center"  then self.justify = 1
      when "right"  then self.justify = 2
    end
  end
end
