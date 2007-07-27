require 'solr'

class SearchRequest < CollexRequest
  def initialize(params = {})
    super('search', params)
  end
  
  def to_hash
    hash = {}
    hash[:start] = @params[:start]
    hash[:rows] = @params[:rows]
    hash[:fl] = @params[:field_list]
    hash[:ff] = @params[:facet_fields]
    hash[:constraint] = constraints

    # Fixed pieces of the query    
    hash[:hl] = "on"
    hash[:"hl.fl"] = 'text'
    hash[:"hl.fragsize"] = 600
    
    hash.merge(super.to_hash)
  end
end
