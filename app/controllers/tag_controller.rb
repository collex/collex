#NUM_VISIBLE_TAGS = 50000
#TAG_INSTRUCTIONS = 'add tag' # TODO-PER: these may not be relevant but were put in to make it not crash
#ANNOTATION_INSTRUCTIONS = 'enter annotation' # TODO-PER: these may not be relevant but were put in to make it not crash

class TagController < ApplicationController
   layout 'collex_tabs'
   #before_filter :authorize, :only => [:collect, :save_search, :remove_saved_search]
   before_filter :init_view_options
   
   # Number of search results to display by default
   MIN_ITEMS_PER_PAGE = 5
   MAX_ITEMS_PER_PAGE = 30

   private
   def init_view_options
     @use_tabs = true
     @use_signin= true
     @site_section = :tag
     return true
   end
   public

  def set_zoom
    # This is called by an ajax request so that the zoom level is remembered for the
    # next time the user visits the page. It doesn't need to render anything or set anything
    # except to save the zoom level.
    level = params[:level]
    case level
      when '1' : session[:tag_zoom] = 1
      when '2' : session[:tag_zoom] = 2
      when '3' : session[:tag_zoom] = 3
      when '4' : session[:tag_zoom] = 4
      when '5' : session[:tag_zoom] = 5
      when '6' : session[:tag_zoom] = 6
      when '7' : session[:tag_zoom] = 7
      when '8' : session[:tag_zoom] = 8
      when '9' : session[:tag_zoom] = 9
      when '10' : session[:tag_zoom] = 10
      else session[:tag_zoom] = 10 
    end
    
    render :nothing => true
  end

  def list
    session[:tag_zoom] ||= 1

    if params[:tag] != nil
      session[:tag_current] = params[:tag]
    else
      params[:tag] = session[:tag_current]
    end

    if params[:which] != nil
      session[:tag_which] = params[:which]
    else
      params[:which] = session[:tag_which]
    end

    if params[:which] == 'all'
      user = nil
      username = ""
    else
      user = session[:user] ? User.find_by_username(session[:user][:username]) : nil
      username = user ? user.username : ""
    end
  
    set_cloud_list(user, username)
  end

  def results
    # parameters:
    #  :which => 'all':'my' (All tags or My tags only)
    #  :view => 'all_collected', 'untagged', 'tag' (show all collected objects, show all untagged objects, show a single tag)
    #  :tag => 'tag_name' (if :view => 'tag', then this is the particular tag to show)
    
    # we save the view type in the session object in case we are called from a place that shouldn't care which type it is.
    # In other words, if we have the param[:view] parameter, we use it and save it. If we don't, then we retrieve it.
    if params[:view] != nil
      session[:tag_view] = params[:view]
    else
      params[:view] = session[:tag_view]
    end
    
    if params[:tag] != nil
      params[:tag] = params[:tag].gsub("&lt;","<").gsub("&gt;", ">").gsub("&amp;", "&").gsub("&quot;", '"')
      session[:tag_current] = params[:tag]
    else
      params[:tag] = session[:tag_current]
    end

    if params[:which] != nil
      session[:tag_which] = params[:which]
    else
      params[:which] = session[:tag_which]
    end

    user = session[:user] ? User.find_by_username(session[:user][:username]) : nil

    if user
      set_cloud_list(user, user.username)
    end
    
    case params[:view]
    when 'all_collected'
      # This creates an array of hits. Hits is a hash with these members: uri, text, title[0], archive, date_label[...], url[0], role_*[...], genre[...], source[...], alternative[...], license
      if user
        @results = sort_by_date_collected(CachedResource.get_all_collections(user))
      else
        @results = {}
      end
      
    when 'untagged'
      if user
        @results = CachedResource.get_all_untagged(user)
      else
        @results = {}
      end
      
    when 'tag'
      @results = sort_by_date_collected(CachedResource.get_hits_for_tag(params[:tag], params[:which] == 'all' ? nil : user))
      
    else
        @results = {}
    end
  
    @total_hits = @results.length
    
    #do the pagination. We have all the results already, but we might want to limit them by cutting off the ones
    # before the current page and after the maximum amount.
    @page = params[:page] ? params[:page].to_i : 1
    session[:items_per_page] ||= MIN_ITEMS_PER_PAGE
    @num_pages = @results.length.quo(session[:items_per_page]).ceil
    
    if @results.length > 0
      # get the first page and make sure it is within bounds.
      first = (@page-1) * session[:items_per_page]
      while first >= @results.length do
        @page -= 1
        first = @page * session[:items_per_page]
      end
    
      # get the last page and make sure it is within bounds
      last = first + session[:items_per_page]
      last = @results.length if last > @results.length
      
      @results = @results.slice(first...last)
    end
  end
  
   # adjust the number of search results per page
   def result_count
     session[:items_per_page] ||= MIN_ITEMS_PER_PAGE
     requested_items_per_page = params['search'] ? params['search']['result_count'].to_i : session[:items_per_page] 
     session[:items_per_page] = (requested_items_per_page <= MAX_ITEMS_PER_PAGE) ? requested_items_per_page : MAX_ITEMS_PER_PAGE
     redirect_to :action => 'results'
   end
   
   def update_sidebar
    user = session[:user] ? User.find_by_username(session[:user][:username]) : nil

    if user
      set_cloud_list(user, user.username)
    end

    render :partial => 'sidebar', :locals => { :cloud_freq => @cloud_freq, :view => session[:tag_view], :tag =>  session[:tag_current] }
   end
   
   private
   
   def sort_by_date_collected(results)
     sorted_results = []
     results.each {|result|
      cr = CachedResource.find_by_uri(result['uri'])
      collects = CollectedItem.find(:all, :conditions => [ "cached_resource_id = ?", cr.id])
      sorted_results.insert(-1, [collects[collects.length-1].updated_at, result])
      str = result.to_s
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
    @cloud_fragment_key = cloud_fragment_key(username)
    
    if is_cache_expired?(@cloud_fragment_key)
      @cloud_freq = CachedResource.tag_cloud(user)
      unless @cloud_freq.empty?
        max_freq = 1
        @cloud_freq.each { |entry| 
          max_freq = entry[1] > max_freq ? entry[1] : max_freq 
        }
        @bucket_size = max_freq.quo(10).ceil
      end     
    end
    
  end
end
