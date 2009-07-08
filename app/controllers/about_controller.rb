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

class AboutController < ApplicationController
  layout 'nines'

  before_filter :init_view_options

  private
  def init_view_options
    @use_tabs = true
    @use_signin= true
    @site_section = :about
    @uses_yui = true
    return true
  end
   
  # This is for the redirects from the old about pages.
  public
  def software
    do_redirect(params)
  end
  
  def scholarship
    do_redirect(params)
  end
  
  def community
    do_redirect(params)
  end
  
  private
  def do_redirect(params)
    headers["Status"] = "301 Moved Permanently"
    params[:page] = 'index' if !params[:page]
    redirect_to "/about/#{params[:action]}/#{params[:page]}.#{params[:ext]}"
  end
end
