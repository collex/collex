require File.expand_path(File.dirname(__FILE__) + '/../../../lib/collex_engine')
class CollexEngine
  BAD_OBJID = "bad"
  def update(username, uri, tags, annotation)
  end

  def remove(username, uri)
  end
  
  def commit
  end
  
  def objects_for_uris(uris, username=nil)
    uris.collect { |uri| {"uri" => uri, "username" => username} }
  end
  
  def object_detail(objid, username)
    objid == BAD_OBJID ? [nil, nil, nil] : [{"uri" => uri, "username" => username}, [], nil]
    
  end
  
  def facet(facet, constraints, field=nil, prefix=nil, username=nil)
    nil
  end
end