require 'solr'

class FacetResponse < Solr::Response::Ruby
  def all_facets
    @data['facets']
  end
  
  def facet(facet)
    @data[facet]
  end
end
