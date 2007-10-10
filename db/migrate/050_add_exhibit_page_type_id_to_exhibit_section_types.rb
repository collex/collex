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

class AddExhibitPageTypeIdToExhibitSectionTypes < ActiveRecord::Migration
  class ExhibitSectionType < ActiveRecord::Base
  end
  
  def self.up
    add_column :exhibit_section_types, :exhibit_page_type_id, :integer
    begin
      @est = ExhibitSectionType.find(1)
      @est.update_attribute(:exhibit_page_type_id, 1)
      @est = ExhibitSectionType.find(2)
      @est.update_attribute(:exhibit_page_type_id, 2)
      @est = ExhibitSectionType.find(3)
      @est.update_attribute(:exhibit_page_type_id, 2)
      @est = ExhibitSectionType.find(4)
      @est.update_attribute(:exhibit_page_type_id, 2)
    rescue
    end
  end

  def self.down
    remove_column :exhibit_section_types, :exhibit_page_type_id
  end
end
