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
  
  MIN_ITEMS_PER_PAGE = 10
  
  #   def details
  #      setup_ajax_calls(params)
  #
  #      render :partial => 'result_row', :locals => { :row_id => @row_id, :page => @page, :index => @index, :hit => @hit }
  #  end
  
  def collect
    # Only collect if the item isn't already collected and if there is a user logged in.
    # This would normally be the case, but there are strange effects if the user is logged in two browsers, or if the user's session was idle too long.
    locals = setup_ajax_calls(params, false)
    if locals[:is_error] == nil
      CollectedItem.collect_item(locals[:user], locals[:uri]) unless locals[:user] == nil || locals[:uri] == nil
    end
    
    render :partial => 'result_row', :locals => { :row_id => locals[:row_id], :index => locals[:index], :hit => locals[:hit], :has_exhibits => locals[:has_exhibits] }
  end
  
  def uncollect
    locals = setup_ajax_calls(params, true)
    CollectedItem.remove_collected_item(user, locals[:uri]) unless locals[:user] == nil || locals[:uri] == nil
    
    render :partial => 'result_row', :locals => { :row_id => locals[:row_id], :index => locals[:index], :hit => locals[:hit], :has_exhibits => locals[:has_exhibits] }
  end
  
  def add_tag
    locals = setup_ajax_calls(params, true)
    tag = params[:tag]
    CollectedItem.add_tag(locals[:user], locals[:uri], tag) unless locals[:user] == nil || locals[:uri] == nil || tag == ""
    
    render :partial => 'result_row', :locals => { :row_id => locals[:row_id], :index => locals[:index], :hit => locals[:hit], :has_exhibits => locals[:has_exhibits] }
  end
  
  def remove_tag
    locals = setup_ajax_calls(params, true)
    tag = params[:tag]
    CollectedItem.delete_tag(locals[:user], locals[:uri], tag) unless locals[:user] == nil || locals[:uri] == nil
    
    render :partial => 'result_row', :locals => { :row_id => locals[:row_id], :index => locals[:index], :hit => locals[:hit], :has_exhibits => locals[:has_exhibits] }
  end
  
  def set_annotation
    locals = setup_ajax_calls(params, true)
    note = params[:note]
    CollectedItem.set_annotation(locals[:user], locals[:uri], note) unless locals[:user] == nil || locals[:uri] == nil
    
    render :partial => 'result_row', :locals => { :row_id => locals[:row_id], :index => locals[:index], :hit => locals[:hit], :has_exhibits => locals[:has_exhibits] }
  end
  
  def bulk_add_tag
    tag = params['tag']
    uris = params['uris']
    uris = uris.split("\t")
    
    user = session[:user] ? User.find_by_username(session[:user][:username]) : nil
    
    if user != nil && tag != nil && tag.length > 0
      uris.each{ |uri|
        CollectedItem.collect_item(user, uri) # this just returns if the object is already collected.
        CollectedItem.add_tag(user, uri, tag)
      }
    end
    redirect_to :back
  end
  
  def bulk_collect
    user = session[:user] ? User.find_by_username(session[:user][:username]) : nil
    if user != nil && params[:bulk_collect] != nil
      uris = params[:bulk_collect]
      uris.each {|key,uri|
        CollectedItem.collect_item(user, uri)
      }
    end

    redirect_to :back
    #redirect_to params[:return]
  end
  
  def edit_tag
    user = session[:user] ? User.find_by_username(session[:user][:username]) : nil
    if user != nil
      old_name = params[:old_name]
      new_name = params[:new_name]
      
      tagged_items = CachedResource.get_hits_for_tag(old_name, user)
      
      tagged_items.each { |item|
        CollectedItem.rename_tag(user, item['uri'], old_name, new_name)
      }
  
    end
    redirect_to :back
  end
  
  def remove_all_tags
    user = session[:user] ? User.find_by_username(session[:user][:username]) : nil
    if user != nil
      tag = params[:tag]
      
      tagged_items = CachedResource.get_hits_for_tag(tag, user)
      
      tagged_items.each { |item|
        CollectedItem.delete_tag(user, item['uri'], tag)
      }
  
    end
    redirect_to :back
  end

  def add_object_to_exhibit
    locals = setup_ajax_calls(params, true)
    exhibit_name = params[:exhibit]
    if locals[:user] != nil
      exhibit = Exhibit.find(:first, :conditions => [ "title = ? AND user_id = ?", exhibit_name, locals[:user].id ] )
      if exhibit == nil
        # TODO-PER: HACK! I don't know why, but sometimes the exhibit name comes back with quotes encrypted. If we can't find the exhibit
        # with this name, then try unencrypting it and trying again. (It is possible that this was just a cached file in the user's browser.)
        name = exhibit_name.gsub("&quot;", '"')
        exhibit = Exhibit.find(:first, :conditions => [ "title = ? AND user_id = ?", name, locals[:user].id ] )
#        arr = exhibit_name.split("")
#        str = '/' + h(arr.join('.')) + "/<br />"
#        arr = name.split("")
#        str += '/' + h(arr.join('.')) + "/<br />"
#        exes = Exhibit.find(:all, :conditions => ["user_id = ?", locals[:user].id])
#        exes.each {|ex|
#          arr = ex.title.split("")
#          str += '/' + h(arr.join('.')) + "/<br />"
#        }
#        locals[:hit]['warning'] = str
      end
      ExhibitObject.add(exhibit.id, locals[:uri])
    end

    render :partial => 'result_row', :locals => { :row_id => locals[:row_id], :index => locals[:index], :hit => locals[:hit], :has_exhibits => locals[:has_exhibits] }
  end

  private
  def setup_ajax_calls(params, is_in_cache)
    # expire the fragment caches for the clouds related to this user
    #expire_timeout_fragment( %r{/cloud/#{session[:user][:username]}_user} )    
    ret = {}
    
    session[:items_per_page] ||= MIN_ITEMS_PER_PAGE
    ret[:user] = session[:user] ? User.find_by_username(session[:user][:username]) : nil
    if is_in_cache
      ret[:hit] = get_from_cache(params[:uri])
    else
      ret[:hit] = get_from_solr(params[:uri])
      if ret[:hit] == nil
        ret[:is_error] = true
        ret[:hit] = get_from_cache(params[:uri])
        ret[:hit] = {} if ret[:hit] == nil
        ret[:hit]['title'] = [ 'Note: This object no longer exists in the index']
      end
    end
    if params[:full_text] && params[:full_text].length > 0
      ret[:hit]['text'] = params[:full_text]
    end
    ret[:uri] = params[:uri]
    ret[:index] = params[:row_num].to_i 
    ret[:row_id] = "search-result-#{ret[:index]}" 

    if ret[:user] != nil
      ret[:has_exhibits] = (Exhibit.find_by_user_id(ret[:user].id) != nil)
    else
      ret[:has_exhibits] = false
    end
    return ret
  end
  
  def get_from_solr(uri)
    @solr = CollexEngine.new(COLLEX_ENGINE_PARAMS) if @solr == nil
    objs = @solr.objects_for_uris([ uri ])
    return objs[0] if objs && objs.length > 0
    return nil
  end

  def get_from_cache(uri)
    return CachedResource.get_hit_from_uri(uri)
  end
end
