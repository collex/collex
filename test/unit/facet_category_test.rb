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

require File.dirname(__FILE__) + '/../test_helper'

class FacetCategoriesTest < Test::Unit::TestCase
  fixtures :facet_categories
  
  def setup
    @archive = FacetCategory.find_by_value("archive")
  end

  def test_basic
    assert_equal 4, @archive.children.size
  end
  
  def test_sorted_facet_tree
    sorted_tree = FacetCategory.sorted_facet_tree()
    assert_not_nil sorted_tree.display_name
    assert_not_nil sorted_tree.sorted_children
    assert sorted_tree.sorted_children.size > 0        
  end
  
  
end
