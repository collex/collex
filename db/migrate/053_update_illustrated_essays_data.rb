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

class UpdateIllustratedEssaysData < ActiveRecord::Migration
  #class ExhibitSectionType < ActiveRecord::Base
  #end
  #
  #def self.up
  #  ExhibitSectionType.delete([2,3,4]) rescue nil
  #  ext = ExhibitSectionType.find_by_template("illustrations")
  #  ext.name = "Generic Illustrated Essay Template"
  #  ext.template = "ie_generic"
  #  ext.description = "Generic Illustrated Essay Template"
  #  ext.save!
  #end
  #
  #def self.down
  #  ext = ExhibitSectionType.find_by_template("ie_generic")
  #  ext.name = "Illustrations Only"
  #  ext.template = "illustrations"
  #  ext.description = "Illustrations Only Section Template"
  #  ext.save!
  #
  #  ExhibitSectionType.delete([2,3,4]) rescue nil
  #  ExhibitSectionType.new do |est|
  #    est.id = 2
  #    est.description = "Text Only"
  #    est.template = "text_only"
  #    est.name = "Text Only"
  #    est.exhibit_page_type_id = 2
  #    est.save!
  #  end
  #
  #  ExhibitSectionType.new do |est|
  #    est.id = 3
  #    est.description = "Illustration on Left"
  #    est.template = "illustration_left"
  #    est.name = "Illustration on Left"
  #    est.exhibit_page_type_id = 2
  #    est.save!
  #  end
  #
  #  ExhibitSectionType.new do |est|
  #    est.id = 4
  #    est.description = "Illustration on Right"
  #    est.template = "illustration_right"
  #    est.name = "Illustration on Right"
  #    est.exhibit_page_type_id = 2
  #    est.save!
  #  end
  #
  #end
end
