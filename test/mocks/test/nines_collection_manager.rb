require 'apis/nines_collection_manager'
class NinesCollectionManager
  def login(username, password)
    {:username => username, :fullname => username}
  end
  
  def add(username, collectables)
    @cache ||= {}
    @cache[username] = collectables
  end

  def object_detail(objid, user)
    [nil, nil, nil]
  end
  
  def cache
    @cache
  end
end