##########################################################################
# Copyright 2007 Applied Research in Patacriticism
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

class AdminMessageController < ApplicationController
  before_filter :allow_only_local

  def add_site
    site = Site.find_or_create_by_code(params[:code])
    site.url = params[:url]
    site.description = params[:description]
    site.thumbnail = params[:thumbnail]
    site.save!
    render :text => "OK"
  end

  private
  def local_request?
    request_ips = [request.remote_addr, request.remote_ip]
    # locahost or jarry hardcoded right now
    (request_ips == ["127.0.0.1"] * 2) || (request_ips == ['128.143.21.77'] * 2)
  end
  
  def allow_only_local
    if !(local_request?)
      render :text => "Only local requests supported", :status => 401
      return false
    end
  end

end
