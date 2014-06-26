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

class ExhibitIllustration < ActiveRecord::Base
  belongs_to :exhibit_element
  acts_as_list :scope => :exhibit_element
  before_save :b4_save
  after_find :aft_find
  has_attached_file :upload, :styles => { :display => "350x350>", :thumb => "50x50>" }

  def b4_save
    if illustration_type == 'Internet Image'
      illustration_type = 0
    elsif illustration_type == 'Textual Illustration'
      illustration_type = 1
    elsif illustration_type == 'NINES Object'
      illustration_type = 2
    else
      illustration_type = -1
    end
  end
  
  def aft_find
    if illustration_type == 0
      illustration_type = 'Internet Image'
    elsif illustration_type == 1
      illustration_type = 'Textual Illustration'
    elsif illustration_type == 2
      illustration_type = 'NINES Object'
    else
      illustration_type = 'Unknown'
    end
  end
  
  def self.get_illustration_type_array
    return "[['NINES Object', '#{Setup.site_name()} Object'], ['Internet Image'], ['Textual Illustration'], ['Upload Image'] ]"
  end
  
  def self.get_illustration_type_array_with_exhibit
	  # this appears to not be used.
    return "['NINES Object', 'NINES Exhibit', 'Internet Image' ]"
  end
  
  def self.get_illustration_type_image
    return 'Internet Image'
  end
  
  def self.get_illustration_type_nines_obj
    return 'NINES Object'
  end
  
  def self.get_illustration_type_text
    return 'Textual Illustration'
  end
  
  def self.get_illustration_type_upload
    return 'Upload Image'
  end

  def self.get_exhibit_type_text
    return 'NINES Exhibit'
  end
  
  def self.factory(element_id, pos)
    illustration = ExhibitIllustration.create(:exhibit_element_id => element_id, :illustration_type => self.get_illustration_type_nines_obj, :illustration_text => "", :caption1 => "", :caption2 => "", :image_width => 100, :link => "" )
    illustration.insert_at(pos)
    return illustration
  end

	def set_caption_footnote(footnote_str, field)
		if footnote_str != nil && footnote_str.length > 0
			if self[field.to_sym] == nil	# if there didn't used to be a footnote, but there is now
				footnote_rec = ExhibitFootnote.create({ :footnote => footnote_str })
				self[field.to_sym] = footnote_rec.id
			else # if there was a footnote and there still is
				footnote_rec = ExhibitFootnote.find(self[field.to_sym])
				footnote_rec.update_attributes({ :footnote => footnote_str })
			end
		else	# There is no footnote specified.
			if self[field.to_sym] != nil	# there used to be a footnote
				footnote_rec = ExhibitFootnote.find(self[field.to_sym])
				footnote_rec.destroy()
				self[field.to_sym] = nil
			end
		end
	end

end
