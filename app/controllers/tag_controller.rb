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

class TagController < ApplicationController
   before_filter :init_view_options
   
   private
   def init_view_options
     @site_section = :tag
	 @solr = Catalog.factory_create(session[:use_test_index] == "true")
	 @archives = @solr.get_resource_tree()
     return true
   end
   public

  def set_zoom
    # This is called by an ajax request so that the zoom level is remembered for the
    # next time the user visits the page. It doesn't need to render anything or set anything
    # except to save the zoom level.
    level = params[:level]
    case level
      when '1' then session[:tag_zoom] = 1
      when '2' then session[:tag_zoom] = 2
      when '3' then session[:tag_zoom] = 3
      when '4' then session[:tag_zoom] = 4
      when '5' then session[:tag_zoom] = 5
      when '6' then session[:tag_zoom] = 6
      when '7' then session[:tag_zoom] = 7
      when '8' then session[:tag_zoom] = 8
      when '9' then session[:tag_zoom] = 9
      when '10' then session[:tag_zoom] = 10
      else session[:tag_zoom] = 10 
    end
    
    render :nothing => true
  end

  # autocomplete tag name based on partial input
  #
  def tag_name_autocomplete 
    str = params['tag']['name']+"%"
    matches = Group.find_by_sql ["select distinct name from tags where name like ?", str]
    @values = []
    matches.each do |match|
       @values.push( match.name )
    end
    render :partial => 'tag_autocomplete'
  end
  
  def list
    session[:tag_zoom] ||= 1

    if params[:tag] != nil
      session[:tag_current] = params[:tag]
    else
      params[:tag] = session[:tag_current]
    end

    set_cloud_list(nil, "")

    respond_to do |format|
      format.xml { render }
      format.html
    end    
  end

  def results
    if params[:script]
      session[:script] = params[:script]
			session[:uri] = params[:uri]
			session[:row_num] = params[:row_num]
			session[:row_id] = params[:row_id]
      params[:script] = nil
      params[:uri] = nil
      params[:row_num] = nil
      params[:row_id] = nil
      redirect_to params
    else
      if session[:script]
        @script = session[:script]
				@uri = session[:uri]
				@row_num = session[:row_num]
				@row_id = session[:row_id]

        session[:script] = nil
        session[:uri] = nil
        session[:row_num] = nil
        session[:row_id] = nil
      end
			# parameters:
			#  :tag => 'tag_name'

			# we save the tag in the session object in case we are called from a place that shouldn't care which type it is.
			if params[:tag] != nil
				params[:tag] = params[:tag].gsub("&lt;","<").gsub("&gt;", ">").gsub("&amp;", "&").gsub("&quot;", '"')
				session[:tag_current] = params[:tag]
			else
				params[:tag] = session[:tag_current]
			end
	  @collected_sort_by = params[:srt] || 'title'
	  @collected_sort_by_direction = params[:dir] || 'asc'
			#do the pagination.
			@page = params[:page] ? params[:page].to_i : 1
			#session[:items_per_page] ||= MIN_ITEMS_PER_PAGE
			items_per_page = 30

			sort_field = 'title'
			case @collected_sort_by
			when "title" then
				sort_field = 'title'
			when "author" then
				sort_field = 'role_AUT'
			when "date" then
				sort_field = 'date_label'	# note: the 'year' field isn't cached, so we can't sort on that. Should we cache it and refresh all objects?
			when "a" then
				sort_field = 'archive'
				else
					sort_field = 'title'
			end

			ret = CachedResource.get_page_of_hits_for_tag(params[:tag], nil, @page-1, items_per_page, sort_field, @collected_sort_by_direction)
			@results = ret[:results]
	  @collected = view_context.add_non_solr_info_to_results(@results, nil)
			@total_hits = ret[:total]

			@num_pages = @total_hits.quo(items_per_page).ceil
		end
  end
  
	 #adjust the sort order
  # def sort_by
	# 	if params['search'] && params['search']['result_sort']
  #     sort_param = params['search']['result_sort']
	# 		session[:tag_sort_by] = sort_param
	# 	end
	# 	if params['search'] && params['search']['result_sort_direction']
  #     sort_param = params['search']['result_sort_direction']
	# 		session[:tag_sort_by_direction] = sort_param
	# 	end
  #     redirect_to :action => 'results'
	# end

   def update_tag_cloud
    if user_signed_in?
      set_cloud_list(current_user, current_user.username)

      selected_tag = (session[:tag_view] == 'tag') ? session[:tag_current] : ""
      render :partial => '/tag/cloud', :locals => { :cloud_info => @cloud_info, :selected_tag => selected_tag, :controller_for_tags => MY_COLLEX_URL, :hide_some => false }
    else
      render :text => 'Session expired. Please log in again.'
    end
   end
   
   def rss
		 if DISALLOW_RSS
			 render :text => 'RSS disabled for this installation'
			 return
		 end

			if params[:tag] != nil
				params[:tag] = params[:tag].gsub("&lt;","<").gsub("&gt;", ">").gsub("&amp;", "&").gsub("&quot;", '"')
			end
     @tag = params[:tag]
     @results = sort_by_date_collected(CachedResource.get_hits_for_tag(params[:tag], nil))
     #@items = [ { :title => 'first', :description => 'this is the first'}, { :title => 'second', :description => 'another entry' } ]
     render :partial => 'rss'
   end
   

    def object
		begin
	      @hit = CachedResource.get_hit_from_uri(params[:uri])
		rescue Catalog::Error => e
			# This can happen if the URI changed on an object after it had been included in an RSS stream.
			logger.error("*** RSS Feed Retrieval Error: #{e.to_s}")
		end
      render :layout => 'simple'
    end
   
   private
   
   def sort_by_date_collected(results)
     sorted_results = []
     results.each {|result|
      cr = CachedResource.find_by_uri(result['uri'])
      collects = CollectedItem.where({cached_resource_id: cr.id})
      if collects.length > 0
        sorted_results.insert(-1, [collects[collects.length-1].updated_at, result])
      end
      #str = result.to_s
     }
    sorted_results.sort! {|a,b| 
        b[0] <=> a[0]
    }
    
    ret_results = []
    sorted_results.each {|result|
      ret_results.insert(-1, result[1])
    }
     return ret_results
   end
   
   def cloud_fragment_key( user )
     "/cloud/#{user}_user/tag"
   end
 
  def set_cloud_list(user, username)
#    @cloud_fragment_key = cloud_fragment_key(username)
#    
#    if is_cache_expired?(@cloud_fragment_key)
      @cloud_info = CachedResource.get_tag_cloud_info(user)
#    end
    
  end
end
