##########################################################################
# Copyright 2007 Applied Research in Patacriticism and the University of Virginia
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

require File.expand_path(File.dirname(__FILE__) + '/../../../lib/collex_engine')
class CollexEngine
  BAD_OBJID = "bad"
  def update_collectables(username, uri, tags, annotation)
  end

  def remove_collectables(username, uri)
  end
  
  def commit
  end
  
  def objects_for_uris(uris, username=nil)
    uris.collect { |uri| {"uri" => uri, "username" => username} }
  end
  
  def object_detail(objid, username)
    objid == BAD_OBJID ? [nil, nil, nil] : [{"uri" => objid, "username" => username}, [], nil]
    
  end
  
  def facet(facet, constraints, prefix=nil)
    nil
  end
end