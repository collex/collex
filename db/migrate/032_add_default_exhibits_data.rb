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

class AddDefaultExhibitsData < ActiveRecord::Migration
  class ExhibitType < ActiveRecord::Base
  end
  class ExhibitSectionType < ActiveRecord::Base
  end

  def self.up
    ExhibitSectionType.delete(1) rescue nil
    exhibit_section_type = ExhibitSectionType.new do |est|
      est.id = 1
      est.description = "Citation"
      est.template = "citation"
      est.name = "Citation"
    end
    exhibit_section_type.save!
    
    ExhibitType.delete([1,2]) rescue nil
    text_exhibit_type = ExhibitType.new do |tet|
      tet.id = 1
      tet.description = "Text"
      tet.template = "text"
    end
    ab_exhibit_type = ExhibitType.new do |abet|
      abet.id = 2
      abet.description = "Annotated Bibliography"
      abet.template = "annotated_bibliography"
    end
    text_exhibit_type.save!
    ab_exhibit_type.save!
  end

  def self.down
    ExhibitSectionType.delete(1) rescue nil
    ExhibitType.delete([1,2]) rescue nil
  end
end
