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

class CreateResources < ActiveRecord::Migration
  def self.up
    create_table :resources do |t|
      t.column :uri, :string, :limit => 512
      t.column :created_on, :datetime
      t.column :updated_on, :datetime
    end
    
    create_table :properties do |t|
      t.column :name, :string
      t.column :value, :string, :limit => 512
      t.column :resource_id, :integer
      t.column :created_on, :datetime
      t.column :updated_on, :datetime
    end

    # migrate interpretation.object_uri to pointers to resource.id and change interpretations to has_one :resource (?)
  end

  def self.down
    drop_table :resources
    drop_table :properties
  end
end
