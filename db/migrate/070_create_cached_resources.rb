##########################################################################
# Copyright 2008 Applied Research in Patacriticism and the University of Virginia
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

class CreateCachedResources < ActiveRecord::Migration
  # In order to facilitate a gradual refactoring and reimplemtation of the caching,
  # cached_resources is just a straight copy of cached_documents rather than a renaming
  # the changed name is to create consistency with the general use of "resource" in the 
  # application to refer to Solr documents.
  def self.up
    create_table :cached_resources do |t|
      t.column :uri, :string
    end
    execute "insert into cached_resources select id, uri from cached_documents"    
    add_index :cached_resources, :uri
  end

  def self.down
    remove_index :cached_resources, :uri
    drop_table :cached_resources
  end
end
