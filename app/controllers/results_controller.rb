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

class ResultsController < ApplicationController
  
  MIN_ITEMS_PER_PAGE = 5
  
  #   def details
  #      setup_ajax_calls(params)
  #
  #      render :partial => 'result_row', :locals => { :row_id => @row_id, :page => @page, :index => @index, :hit => @hit }
  #  end
  
  def collect
    # Only collect if the item isn't already collected and if there is a user logged in.
    # This would normally be the case, but there are strange effects if the user is logged in two browsers, or if the user's session was idle too long.
    locals = setup_ajax_calls(params, false)
    CollectedItem.collect_item(locals[:user], locals[:uri]) unless locals[:user] == nil || locals[:uri] == nil
    
    render :partial => 'result_row', :locals => { :row_id => locals[:row_id], :index => locals[:index], :hit => locals[:hit] }
  end
  
  def uncollect
    locals = setup_ajax_calls(params, true)
    CollectedItem.remove_collected_item(user, locals[:uri]) unless locals[:user] == nil || locals[:uri] == nil
    
    render :partial => 'result_row', :locals => { :row_id => locals[:row_id], :index => locals[:index], :hit => locals[:hit] }
  end
  
  def add_tag
    locals = setup_ajax_calls(params, true)
    tag = params[:tag]
    CollectedItem.add_tag(locals[:user], locals[:uri], tag) unless locals[:user] == nil || locals[:uri] == nil || tag == nil
    
    render :partial => 'result_row', :locals => { :row_id => locals[:row_id], :index => locals[:index], :hit => locals[:hit] }
  end
  
  def remove_tag
    locals = setup_ajax_calls(params, true)
    tag = params[:tag]
    CollectedItem.delete_tag(locals[:user], locals[:uri], tag) unless locals[:user] == nil || locals[:uri] == nil
    
    render :partial => 'result_row', :locals => { :row_id => locals[:row_id], :index => locals[:index], :hit => locals[:hit] }
  end
  
  def set_annotation
    locals = setup_ajax_calls(params, true)
    note = params[:note]
    CollectedItem.set_annotation(locals[:user], locals[:uri], note) unless locals[:user] == nil || locals[:uri] == nil
    
    render :partial => 'result_row', :locals => { :row_id => locals[:row_id], :index => locals[:index], :hit => locals[:hit] }
  end
  
  private
  def setup_ajax_calls(params, is_in_cache)
    # expire the fragment caches for the clouds related to this user
    #expire_timeout_fragment( %r{/cloud/#{session[:user][:username]}_user} )    
    ret = {}
    
    session[:items_per_page] ||= MIN_ITEMS_PER_PAGE
    ret[:user] = session[:user] ? User.find_by_username(session[:user][:username]) : nil
    if is_in_cache
      ret[:hit] = get_from_cache(params[:uri], ret[:user])
    else
      ret[:hit] = get_from_solr(params[:uri])
    end
    ret[:uri] = params[:uri]
    ret[:index] = params[:row_num].to_i 
    ret[:row_id] = "search-result-#{ret[:index]}" 
    return ret
  end
  
  def get_from_solr(uri)
    @solr = CollexEngine.new(COLLEX_ENGINE_PARAMS) if @solr == nil
    objs = @solr.objects_for_uris([ uri ])
    return objs[0] if objs && objs.length > 0
    return nil
  end

  def get_from_cache(uri, user)
    return CachedResource.get_hit_from_uri(uri)
  end
end
