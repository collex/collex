require 'solr'

class ObjectResponse < Solr::Response::Ruby
  def doc
    @data['docs']['docs'][0]
  end
  
  def docs
    @data['docs']['docs']
  end
  
  def mlt
    @data['mlt'][1]['docs']
  end
  
  def users
    @data['collectable'][1][@data['collectable'][1].index('users') + 1]
  end
end
