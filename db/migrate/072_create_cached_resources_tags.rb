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

class CreateCachedResourcesTags < ActiveRecord::Migration
  def self.up
    create_table :cached_resources_tags, :id => false do |t|
      t.column :cached_resource_id, :integer
      t.column :tag_id, :integer
    end
    #copy over existing cached_documents_tags into this table
    execute "insert into cached_resources_tags (cached_resource_id, tag_id) select cached_document_id as cached_resource_id, tag_id from cached_documents_tags"
  end

  def self.down
    drop_table :cached_resources_tags
  end
end
