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

class Log < ActiveRecord::Base
  def self.append_record(session, env, params)
    user = session[:user] ? session[:user][:username] : nil

    str = ""
    for param in params
      str += "#{param[0]} => \"#{param[1]}\", " if param[0] != 'action' and param[0] != 'controller'
    end
    
    count = Log.count
    if count >= 10000
      log = Log.find(:first, :order => 'updated_at')
      log.user = user
      log.request_method = env['REQUEST_METHOD']
      log.request_uri = env['REQUEST_URI']
      log.http_referer = env["HTTP_REFERER"]
      log.params = str
      log.save
    else
      Log.create(:user => user, :request_method => env['REQUEST_METHOD'], :request_uri => env['REQUEST_URI'], :http_referer => env["HTTP_REFERER"], :params => str)
    end
    
  end
end
