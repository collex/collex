require 'solr'

class SearchResponse < Solr::Response::Ruby
  def facets
    @data['facets']
  end
  
  def docs
    @data['response']['docs']
  end
  
  def highlighting
    @data['highlighting']
  end
  
  def total_hits
    @data['response']['numFound']
  end
end
