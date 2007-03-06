require 'solr'

class FacetRequest < CollexRequest
  def initialize(params = {})
    super('facet', params)
  end
  
  def to_hash
    hash = {}
    hash[:facet] = @params[:facet]
    hash[:constraint] = "type:A"
    if @params[:prefix] and @params[:field]
      hash[:field] = @params[:field]
      hash[:prefix] = @params[:prefix].downcase
    end
    if @params[:username]
      hash[:username] = @params[:username]
    end
    hash[:constraint] = constraints
    hash.merge(super.to_hash)
  end
end
