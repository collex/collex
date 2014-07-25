##########################################################################
# Copyright 2009 Applied Research in Patacriticism and the University of Virginia
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################

class ExhibitObject < ActiveRecord::Base
  belongs_to :exhibit
  
  def self.add(exhibit_id, uri)
	  # Don't add a nil or blank object
	  return nil if uri == nil || uri.length == 0

    # Don't add a duplicate
    obj = self.find_by_exhibit_id_and_uri(exhibit_id, uri)
    return obj if obj != nil
    
    return self.create(:exhibit_id => exhibit_id, :uri => uri)
  end
  
  def self.set_objects(exhibit_id, objects)
    destroy_all(["exhibit_id = ?", exhibit_id]) 

    objects.each {|obj|
      self.add(exhibit_id, obj)
    }
  end
  
  def self.get_collected_object_array(exhibit_id)
    objs = where({exhibit_id: exhibit_id})
    str = ""
    objs.each {|obj|
    hit = CachedResource.get_hit_from_uri(obj.uri)
      if hit != nil
        image = CachedResource.get_thumbnail_from_hit(hit)
        image = ActionController::Base.new.view_context.image_path(DEFAULT_THUMBNAIL_IMAGE_PATH) if image == "" || image == nil
        if str != ""
          str += ",\n"
        end
        str += "{ uri: '#{obj.uri}', thumbnail: '#{image}', title: '#{self.escape_quote(hit['title'])}'}"
      end
    }
    
    return '[' + str + ']'
  end
  
  def self.get_collected_object_thumbnail_array(exhibit_id)
    objs = where({exhibit_id: exhibit_id})
    arr = []
    objs.each {|obj|
    hit = CachedResource.get_hit_from_uri(obj.uri)
      if hit != nil
        image = CachedResource.get_thumbnail_from_hit(hit)
        image = ActionController::Base.new.view_context.image_path(DEFAULT_THUMBNAIL_IMAGE_PATH) if image == "" || image == nil
        arr.insert(-1, { :image => image, :title => self.escape_quote(hit['title']), :uri => obj.uri } )
      end
    }
    
    return arr
  end
  
  def self.escape_quote(arr)
    return '' if arr == nil
    str = arr.gsub("\n", " ").gsub("\r", " ")
    return str.gsub("'", "`") #TODO-PER: get the real syntax for this. We want to replace "single quote" with "backslash single quote"
  end
end
