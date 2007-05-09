class FacetCategory < ActiveRecord::Base
  acts_as_tree
  
  attr_accessor :facet_count
  
  def to_facet_tree(facets)
    # child is from the DB, kid is our home-grown tree
    kids = []
    children.each do |child|
      facet_count = facets[child.name]
      kids << {:children => child.to_facet_tree(facets), :name => child.name, :count => facet_count}
      if !facet_count
        kids.each do |kid|
          kid[:count] = total(kid[:children])
        end
      else
        # remove from uncategorized
        # TODO
      end
    end
    
    kids
  end
  
  def total(kids)
    total = 0
    kids.each do |kid|
      total += total(kid[:children]) + (kid[:count] || 0)
    end
    
    total
  end
  
end
