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

class CreateFacetCategories < ActiveRecord::Migration
  def self.up
#    create_table :facet_categories do |t|
#      t.column :parent_id, :integer
#      t.column :value, :string
#      t.column :type, :string
#    end

#    # Create initial set of archive facet categories
#    archive = FacetTree.create(:value => 'archive')
#
#    # Categories under the archive facet tree
#    libraries = FacetCategory.new(:value => 'Libraries')
#    journals = FacetCategory.new(:value => 'Journals')
#    presses = FacetCategory.new(:value => 'Presses')
#    projects = FacetCategory.new(:value => 'Projects')
#
#    archive << libraries
#    archive << journals
#    archive << presses
#    archive << projects
#
#    # Libraries
#    # Journals
#    # Presses
#
#    # Projects
#    projects << FacetValue.new(:value => 'rossetti')
#
#    archive.save
  end

  def self.down
    drop_table :facet_categories
  end
end
