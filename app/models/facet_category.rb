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
