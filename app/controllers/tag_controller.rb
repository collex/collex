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
  end

  def results
    # parameters:
    #  :all_tags => true|false (All tags or My tags only)
    #  :view => 'all collected', 'untagged', 'tag' (show all collected objects, show all untagged objects, show a single tag)
    #  :tag => 'tag_name' (if :view => 'tag', then this is the particular tag to show)
  end
end
