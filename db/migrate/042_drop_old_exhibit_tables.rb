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

class DropOldExhibitTables < ActiveRecord::Migration
  def self.up
    drop_table :exhibit_types_section_types
    drop_table :panel_types
    drop_table :panel_types_section_types
    drop_table :section_types
    drop_table :sections
  end

  def self.down
    create_table "exhibit_types_section_types", :force => true do |t|
      t.column "exhibit_type_id", :integer
      t.column "section_type_id", :integer
    end

    create_table "panel_types", :force => true do |t|
      t.column "description", :string
      t.column "template",    :text
    end

    create_table "panel_types_section_types", :force => true do |t|
      t.column "panel_type_id",   :integer
      t.column "section_type_id", :integer
    end

    create_table "section_types", :force => true do |t|
      t.column "description", :string
    end
    
    create_table "sections", :force => true do |t|
      t.column "section_type_id", :integer
      t.column "exhibit_id",      :integer
    end
  end
end
