##########################################################################
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
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
  
  def <<(sapling)
    children << sapling
  end
  
  def merge_facets(facets, uncategorized)
    # child is from the DB, kid is our home-grown tree
    kids = []
    children.each do |child|
      case child
        when FacetValue  # Order matters: FacetValue is_a? FacetCategory, so trap that first
          facet_count = facets[child.value] || 0
          kids << {:children => [], :value => child.value, :count => facet_count, :type => :value, :id => child.id}
          uncategorized.delete(child.value)
        when FacetCategory
          category = {:children => child.merge_facets(facets,uncategorized), :value => child.value, :count => 0, :type => :category, :id => child.id}
          kids << category
          category[:count] = total(category[:children])
      end
    end
    
    kids
  end
  
  def total(kids)
    total = 0
    kids.each do |kid|
      total += total(kid[:children]) + (kid[:type] == :value ? (kid[:count] || 0) : 0)
    end
    
    total
  end
  
end
