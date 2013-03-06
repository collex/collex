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

class HelpController < ApplicationController
  #layout 'popup'

  def sites
    @sites = Catalog.factory_create(false).get_archives() #Site.find(:all, :order => "description ASC")
	@sites = @sites.delete_if {|site| site['handle'].index('exhibit_') == 0 }
    render :partial => '/help/sites'
  end
  
  def resources
    render :partial => '/help/resources'
  end
end
