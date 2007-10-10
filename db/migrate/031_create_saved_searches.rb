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

class CreateSavedSearches < ActiveRecord::Migration
  def self.up
    create_table :searches do |t|
      t.column :name, :string
      t.column :user_id, :integer
    end
    
    create_table :constraints do |t|
      t.column :search_id, :integer
      t.column :inverted, :boolean
      t.column :type, :string
      
      # :field and :value are used differently, based on the :type
      t.column :field, :string
      t.column :value, :string
    end
  end

  def self.down
    drop_table :searches
  end
end
