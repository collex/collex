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

class AddIllustratedEssayData < ActiveRecord::Migration
  class ExhibitType < ActiveRecord::Base
  end
  class ExhibitSectionType < ActiveRecord::Base
  end

  def self.up
    ExhibitSectionType.delete([2,3,4]) rescue nil
    exhibit_section_type = ExhibitSectionType.new do |est|
      est.id = 2
      est.description = "Text Only"
      est.template = "text_only"
      est.name = "Text Only"
    end
    exhibit_section_type.save!
    exhibit_section_type = ExhibitSectionType.new do |est|
      est.id = 3
      est.description = "Illustration on Left"
      est.template = "illustration_left"
      est.name = "Illustration on Left"
    end
    exhibit_section_type.save!
    exhibit_section_type = ExhibitSectionType.new do |est|
      est.id = 4
      est.description = "Illustration on Right"
      est.template = "illustration_right"
      est.name = "Illustration on Right"
    end
    exhibit_section_type.save!
    
    ExhibitType.delete([3]) rescue nil
    ie_exhibit_type = ExhibitType.new do |et|
      et.id = 3
      et.description = "Illustrated Essay"
      et.template = "illustrated_essay"
    end
    ie_exhibit_type.save!
  end

  def self.down
    ExhibitSectionType.delete([2,3,4]) rescue nil
    ExhibitType.delete(3) rescue nil
  end
end
