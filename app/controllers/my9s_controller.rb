class My9sController < ApplicationController
  layout 'collex_tabs'
  before_filter :init_view_options

   # Number of search results to display by default
   MIN_ITEMS_PER_PAGE = 10
   MAX_ITEMS_PER_PAGE = 30

  private
  def init_view_options
    @use_tabs = true
    @use_signin= true
    @site_section = :my9s
    return true
  end
  public
 
  def index
    user = session[:user] ? User.find_by_username(session[:user][:username]) : nil
    if user == nil
      return
    end
      
    set_cloud_list(user, user.username)
    
    @results = sort_by_date_collected(CachedResource.get_all_collections(user))
    if @results.length > 5
      @results = @results.slice(0...5)
    end
  end
  
  def results
    user = session[:user] ? User.find_by_username(session[:user][:username]) : nil
    if user == nil
      return
    end

    # parameters:
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
      @results = sort_by_date_collected(CachedResource.get_hits_for_tag(params[:tag], user))
      
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
    if (user == nil)  # in case the session times out while the page is displayed. This page expects a user to be logged in.
      redirect_to "/"
      return
    end

    if user
      set_cloud_list(user, user.username)
    end

    render :partial => 'sidebar', :locals => { :cloud_freq => @cloud_freq, :view => session[:tag_view], :tag =>  session[:tag_current] }
   end

  # This is called from AJAX to display the edit profile form in place.
  def enter_edit_profile_mode
    user = session[:user] ? User.find_by_username(session[:user][:username]) : nil
    if (user == nil)  # in case the session times out while the page is displayed. This page expects a user to be logged in.
      render :text => "You must be logged in to perform this function. Did your session time out due to inactivity?"
      return
    end
    
    render :partial => 'profile', :locals => { :user => user, :edit_mode => true }
  end
  
  # This is called from AJAX when the user has finished filling out the form.
  def update_profile
    user = session[:user] ? User.find_by_username(session[:user][:username]) : nil
    if (user == nil)  # in case the session times out while the page is displayed. This page expects a user to be logged in.
      render :text => "You must be logged in to perform this function. Did your session time out due to inactivity?"
      return
    end

    # if we weren't called with any parameters, then the user meant to cancel the operation
    if params['institution'] == nil
      render :partial => 'profile', :locals => { :user => user, :edit_mode => false }
    else
      user.institution = params['institution']
      user.fullname = params['fullname']
      user.link = params['link']
      user.about_me = params['aboutme']
      #check the link for a javascript attack
      if user.link.downcase.index("javascript:") != nil
        user.link = "invalid link entered"
      end
      if params['image'].length > 0
        folder = "#{RAILS_ROOT}/public/images/users/"
        image_path = "#{folder}#{user.id}"
        Dir.mkdir(folder) unless File.exists?(folder)
        File.open(image_path, "wb") { |f| f.write(params['image'].read) }
      end
      user.save
     redirect_to :action => 'index'
    end
  end
  
   def remove_saved_search
     if (session[:user])
       user = User.find_by_username(session[:user][:username])
       searches = user.searches
       saved_search = searches.find(params[:id])
  
       #session[:constraints].delete_if {|item| item.is_a?(SavedSearchConstraint) && item.field == session[:user][:username] && item.value == saved_search.name }
       
       saved_search.destroy
     end
     
     redirect_to :action => 'index'
   end

    def new_exhibit
      if (session[:user])
        user = User.find_by_username(session[:user][:username])
        exhibit = Exhibit.create(:title =>'Untitled', :user_id => user.id)
        ExhibitPage.create(:exhibit_id => exhibit.id, :position => 1) # create a page because we know the user will need at least one.
        redirect_to :action => 'edit_exhibit', :id => exhibit.id
      else
        redirect_to :action => 'index'
      end
    end
    
    def edit_exhibit
      @exhibit = Exhibit.find(params[:id])
      @page = params['page'] == nil ? 1 : params['page'].to_i
    end

    def edit_exhibit_globals
      exhibit = Exhibit.find(params['id'])
      exhibit.title = params['title']
      exhibit.thumbnail = params['thumbnail']
      exhibit.visible_url = params['visible_url']
      exhibit.is_published = (params['is_published'] == 'Published' ? 1 : 0)
      exhibit.save
      redirect_to :action => 'edit_exhibit', :id => exhibit.id
    end
  
    def delete_exhibit
      # for security reasons, make sure that the exhibit belongs to the person who is trying to delete it.
      if (session[:user])
        user = User.find_by_username(session[:user][:username])
        exhibit = Exhibit.find(params[:id])
        if exhibit.user_id == user.id
          Exhibit.destroy(params[:id])
        end
      end

      redirect_to :action => 'index'
    end
    
    def change_page
      redirect_to :action => 'edit_exhibit', :id => params['id'], :page => params['page']
    end

    def edit_page
      id = params[:id]
      page = params[:page].to_i
      verb = params[:verb]
      exhibit = Exhibit.find(id)
      pages = exhibit.exhibit_pages
      curr_page = pages[page-1]
      
      case verb
      when "up"
        curr_page.move_higher()
      when "down"
        curr_page.move_lower()
      when "insert"
        new_section = ExhibitPage.create(:exhibit_id => id)
        new_section.insert_at(page)
      when "delete"
        curr_page.remove_from_list()
        curr_page.destroy
      end

      redirect_to :action => 'edit_exhibit', :id => id, :page => page
    end
    
    def edit_section
      page_id = params[:page].to_i
      section_pos = params[:section].to_i
      verb = params[:verb]
      
      page = ExhibitPage.find(page_id)
      
      case verb
      when "up"
        page.exhibit_sections[section_pos-1].move_higher()
      when "down"
        page.exhibit_sections[section_pos-1].move_lower()
      when "insert"
        new_section = ExhibitSection.create(:has_border => true, :exhibit_page_id => page.id)
        new_section.insert_at(section_pos)
      when "delete"
        page.exhibit_sections[section_pos-1].remove_from_list()
        page.exhibit_sections[section_pos-1].destroy
      when "add_border"
        page.exhibit_sections[section_pos-1].has_border = 1
        page.exhibit_sections[section_pos-1].save
      when "remove_border"
        page.exhibit_sections[section_pos-1].has_border = 0
        page.exhibit_sections[section_pos-1].save
      end

      render :partial => 'edit_exhibit_page', :locals => { :page => ExhibitPage.find(page_id) }
    end
    
    def edit_element
      page_id = params[:page].to_i
      section_id = params[:section].to_i
      element_pos = params[:element].to_i
      verb = params[:verb]

      section = ExhibitSection.find(section_id)
      
      case verb
      when "up"
        section.exhibit_elements[element_pos-1].move_higher()
      when "down"
        section.exhibit_elements[element_pos-1].move_lower()
      when "insert"
        new_element = ExhibitElement.create(:exhibit_section_id => section.id, :exhibit_element_layout_type => 'text', :element_text => "Enter Your Text Here")
        new_element.insert_at(element_pos)
      when "delete"
        section.exhibit_elements[element_pos-1].remove_from_list()
        section.exhibit_elements[element_pos-1].destroy
      when "layout"
        section.exhibit_elements[element_pos-1].exhibit_element_layout_type = params[:type]
        section.exhibit_elements[element_pos-1].save
      end

      # We need to get the records again because the local variables are probably stale.
      render :partial => 'edit_exhibit_section', :locals => { :section => ExhibitSection.find(section_id), :page => ExhibitPage.find(page_id) }
    end
    
    def insert_illustration
      element_id = params[:element_id]
      pos = params[:position]
      element = ExhibitElement.find(element_id)

      new_illustration = ExhibitIllustration.create(:exhibit_element_id => element_id, :illustration_type => 'image', :illustration_text => "", :caption1 => "", :caption2 => "", :image_width => 100, :link => "" )
      new_illustration.insert_at(pos)

      render :partial => 'edit_exhibit_element', :locals => { :element => element } 
    end
    
    def change_element_type
      element_id = params[:element_id]
      type = params[:type]
      element = ExhibitElement.find(element_id)
      element.exhibit_element_layout_type = type
      element.save
      render :partial => 'edit_exhibit_element', :locals => { :element => element } 
    end
    
    def edit_text
      element = params['editorId']
      arr = element.split('_')
      element_id = arr[arr.length-1].to_i
      
      value = params['value']
      element = ExhibitElement.find(element_id)
      element.element_text = value
      element.save
      render :text=> value
    end
    
    def edit_header
      element = params['editorId']
      arr = element.split('_')
      element_id = arr[arr.length-1].to_i
      
      value = params['value']
      element = ExhibitElement.find(element_id)
      element.element_text = value
      element.save
      render :text=> value
    end
    
    def change_img_width
      element = params['illustration_id']
      arr = element.split('_')
      element_id = arr[arr.length-1].to_i
      width = params['width'].to_i
      if element_id == 0
        illustration = ExhibitIllustration.create(:exhibit_element_id => element_id, :illustration_type => 'image', :illustration_text => "", :caption1 => "", :caption2 => "", :image_width => width, :link => "" )
        illustration.insert_at(1)
      else
        illustration = ExhibitIllustration.find(element_id)
        illustration.image_width = width
        illustration.save
      end
      render :text=> ""
    end
    
    def edit_illustration
      element_id = params['element_id']
      illustration_id = params['illustration_id'].to_i
      image_url = params['image_url']
      type = params['type']
      link = params['link']
      width = params['width']
      caption1 = params['caption1']
      caption2 = params['caption2']
      text = params['text']

      if illustration_id < 0
        illustration = ExhibitIllustration.create(:exhibit_element_id => element_id, :position => 1, :illustration_type => type, :image_url => image_url, :illustration_text => text, :caption1 => caption1,
          :caption2 => caption2, :image_width => width, :link => link)
      else
        illustration = ExhibitIllustration.find(illustration_id)
        illustration.illustration_type = type
        illustration.image_url = image_url
        illustration.illustration_text = text
        illustration.caption1 = caption1
        illustration.caption2 = caption2
        illustration.image_width = width
        illustration.link = link
        illustration.save
      end

      element = ExhibitElement.find(element_id)
      render :partial => 'edit_exhibit_element', :locals => { :element => element } 
    end
    
  private
    #TODO-PER: This is repeated in tag_controller.rb
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
