require 'solr'

class SearchRequest < CollexRequest
  def initialize(params = {})
    super('search', params)
  end
  
  def to_hash
    hash = {}
    hash[:start] = @params[:start]
    hash[:rows] = @params[:rows]
    hash[:constraint] = constraints

    # Fixed pieces of the query    
    hash[:fl] = "archive,agent,date_label,genre,role_*,source,thumbnail,title,alternative,uri,url"
    hash[:ff] = ['genre','archive','freeculture']
    hash[:hl] = "on"
    hash[:"hl.fl"] = 'text'
    hash[:"hl.fragsize"] = 600
    
    hash.merge(super.to_hash)
  end
end
