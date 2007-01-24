require File.expand_path(File.dirname(__FILE__) + '/../../../lib/nines_collection_manager')
class NinesCollectionManager
  def login(username, password)
    {:username => username, :fullname => username}
  end
  
  def add(username, collectables)
    @cache ||= {}
    @cache[username] = collectables
  end

  def objects_behind_urls(urls, user)
    []
  end

  def object_detail(objid, user)
    [nil, nil, nil]
  end
  
  def cache
    @cache
  end
end