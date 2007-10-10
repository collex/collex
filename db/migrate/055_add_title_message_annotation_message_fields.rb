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

class AddTitleMessageAnnotationMessageFields < ActiveRecord::Migration
  class ExhibitType < ActiveRecord::Base
  end
  class ExhibitPageType < ActiveRecord::Base
  end
  class ExhibitSectionType < ActiveRecord::Base
  end

  def self.up
    add_column :exhibit_types, :title_message, :string
    add_column :exhibit_types, :annotation_message, :string
    
    add_column :exhibit_page_types, :title_message, :string
    add_column :exhibit_page_types, :annotation_message, :string
    
    add_column :exhibit_section_types, :title_message, :string
    add_column :exhibit_section_types, :annotation_message, :string
    
    ann_bib = ExhibitType.find_by_template "annotated_bibliography"
    ExhibitType.update ann_bib.id, :title_message => "(Insert Bibliography Title)", :annotation_message => "(Insert General Description)" rescue nil

    ill_ess = ExhibitType.find_by_template "illustrated_essay"
    ExhibitType.update ill_ess.id, :title_message => "(Insert Essay Title)", :annotation_message => "(Insert Abstract)" rescue nil
    
    ann_bib_page = ExhibitPageType.find_by_name "Annotated Bibliography Page Type"
    ExhibitPageType.update ann_bib_page.id, :title_message => "(Insert Page Title)", :annotation_message => "(Insert Page Notes)" rescue nil

    ill_ess_page = ExhibitPageType.find_by_name "Illustrated Essay Page Type"
    ExhibitPageType.update ill_ess_page.id, :title_message => "(Insert Page Title)", :annotation_message => "(Insert Page Notes)" rescue nil
    
    ann_bib_section = ExhibitSectionType.find_by_template "citation"
    ExhibitSectionType.update ann_bib_section.id, :title_message => "(Insert Section Title)", :annotation_message => "(Insert Section Description)" rescue nil

    ill_ess_section = ExhibitSectionType.find_by_template "ie_generic"
    ExhibitSectionType.update ill_ess_section.id, :title_message => "(Insert Section Title)", :annotation_message => "(Insert Text)" rescue nil
  end

  def self.down
    remove_column :exhibit_types, :title_message
    remove_column :exhibit_types, :annotation_message
    
    remove_column :exhibit_page_types, :title_message
    remove_column :exhibit_page_types, :annotation_message
    
    remove_column :exhibit_section_types, :title_message
    remove_column :exhibit_section_types, :annotation_message
  end
end
