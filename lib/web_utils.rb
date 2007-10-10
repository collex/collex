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

module WebUtils
   # Fetch method copied from PickAxe, p. 700
   def WebUtils.fetch_html(url, limit=10)
      fail 'http redirect too deep' if limit.zero?
      
      response = Net::HTTP.get_response(URI.parse(url))
      
      case response
         when Net::HTTPSuccess
            response
         when Net::HTTPRedirection
            fetch_html(response['location'], limit - 1)
         else
            response.error!
      end
   end   
end
