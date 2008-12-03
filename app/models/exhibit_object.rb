class ExhibitObject < ActiveRecord::Base
  belongs_to :exhibit
  
  def self.add(exhibit_id, uri)
    return self.create(:exhibit_id => exhibit_id, :uri => uri)
  end
  
  def self.get_collected_object_array(exhibit_id)
    objs = find_all_by_exhibit_id(exhibit_id)
    str = "["
    objs.each {|obj|
    hit = CachedResource.get_hit_from_uri(obj.uri)
      if hit != nil
        #str += "{ thumbnail: '#{hit['thumbnail']}', title: '#{hit['title']}' },\n"
        str += "{ thumbnail: '#{self.escape_quote(hit['thumbnail'])}', title: '#{self.escape_quote(hit['title'])}'},\n"
      end
    }
    str += ']'
    return str
  end
  
  def self.escape_quote(arr)
    return '' if arr == nil
    return '' if arr[0] == nil
    return arr[0].gsub("'", "`") #TODO-PER: get the real syntax for this
  end
end
