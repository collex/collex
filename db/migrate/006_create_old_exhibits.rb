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

class CreateOldExhibits < ActiveRecord::Migration
  def self.up
    create_table :exhibits do |t|
      t.column :user_id, :integer
      t.column :license_id, :integer
      t.column :title, :string
      t.column :exhibit_type_id, :integer
    end
  end

  def self.down
    drop_table :exhibits
  end
end
