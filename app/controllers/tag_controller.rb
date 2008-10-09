NUM_VISIBLE_TAGS = 50000
TAG_INSTRUCTIONS = 'add tag' # TODO-PER: these may not be relevant but were put in to make it not crash
ANNOTATION_INSTRUCTIONS = 'enter annotation' # TODO-PER: these may not be relevant but were put in to make it not crash

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

  def list
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
        @results = CachedResource.get_all_collections(user)
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
      @results = CachedResource.get_hits_for_tag(params[:tag], params[:which] == 'all' ? nil : user)
      
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
   
   private
   def cloud_fragment_key( type, user, max )
     "/cloud/#{user}_user/#{type}_#{max}_sidebar"
   end
 
  def set_cloud_list(user, username)
    @cloud_fragment_key = cloud_fragment_key('tag', username, NUM_VISIBLE_TAGS)
    
    if is_cache_expired?(@cloud_fragment_key)
      @cloud_freq = CachedResource.cloud('tag', user, NUM_VISIBLE_TAGS)
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
