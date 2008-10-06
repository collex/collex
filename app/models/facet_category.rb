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

class FacetCategory < ActiveRecord::Base
  acts_as_tree
  
  attr :display_name, true
  attr :sorted_children, true
  
  def self.sorted_facet_tree()
    tree_root = FacetCategory.find_by_value('archive')
    self.recursively_sort_tree( tree_root )
  end

  private 
  def self.recursively_sort_tree( node )    
    if node[:type] == 'FacetValue'
      site = Site.find_by_code(node.value)
      node.display_name = site ? site.description : node.value      
    else
      node.display_name = node.value
    end
    
    if node.children
      named_children = node.children.map { |child| self.recursively_sort_tree(child) }      
      node.sorted_children = named_children.sort { |a,b| a.display_name.downcase <=> b.display_name.downcase }    
    end
    
    node
  end
  
  
end
