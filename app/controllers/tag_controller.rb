NUM_VISIBLE_TAGS = 50

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
    if params[:all_tags]
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
    #  :all_tags => true|false (All tags or My tags only)
    #  :view => 'all_collected', 'untagged', 'tag' (show all collected objects, show all untagged objects, show a single tag)
    #  :tag => 'tag_name' (if :view => 'tag', then this is the particular tag to show)
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
      @results = CachedResource.get_hits_for_tag(params[:tag], params[:all_tags] ? nil : user)
    end
  
    @total_hits = @results.length
    @page = 1
    @num_pages = 1
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
