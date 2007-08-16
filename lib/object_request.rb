require 'solr'

class ObjectRequest < CollexRequest
  def initialize(params = {})
    super('object', params)
  end
  
  def to_hash
    hash = {}
    hash[:field] = @params[:field]
    hash[:value] = @params[:value]
    hash[:username] = @params[:username]
    hash[:rows] = @params[:rows]

    hash[:fl] = 'title,alternative,genre,year,date_label,archive,agent,role_*,uri,url,thumbnail,source'
    hash.merge(super.to_hash)
  end
end
