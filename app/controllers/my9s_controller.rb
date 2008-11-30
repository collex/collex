#require 'tiny_mce'
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
    @uses_tiny_mce = true
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
        exhibit = Exhibit.factory(user.id)
        redirect_to :action => 'edit_exhibit', :id => exhibit.id
      else
        redirect_to :action => 'index'
      end
    end
    
    def edit_exhibit
      @exhibit = Exhibit.find(params[:id])
      @page = params['page'] == nil ? 1 : params['page'].to_i
#      uses_tiny_mce :options => {
#                              :theme => 'advanced',
#                              :theme_advanced_resizing => true,
#                              :theme_advanced_resize_horizontal => false,
#                              :plugins => %w{ table fullscreen }
#                            }
    end

    def edit_exhibit_globals
      exhibit = Exhibit.find(params['id'])
      exhibit.title = params['title']
      exhibit.thumbnail = params['thumbnail']
      ex = Exhibit.find_by_visible_url(params['visible_url'])
      if ex == nil
        exhibit.visible_url = params['visible_url']
      else
        flash[:warning] = "The url \"http://nines.org/exhibits/#{params['visible_url']}\" has already been used by another project. Choose a different Visual URL."
      end
      
      exhibit.is_published = (params['is_published'] == 'Visible to Everyone' ? 1 : 0)
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
      
      case verb
      when "up"
        exhibit.move_page_up(page)
        page = page - 1
      when "down"
        exhibit.move_page_down(page)
        page = page + 1
      when "insert"
        exhibit.insert_page(page)
      when "delete"
        exhibit.delete_page(page)
        page = page - 1 if page == exhibit.exhibit_pages.length
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
        page.insert_section(section_pos)
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
      should_redraw = true
      
      case verb
      when "up"
        section.move_element_up(element_pos)
      when "down"
        section.move_element_down(element_pos)
      when "insert"
        section.insert_element(element_pos)
      when "delete"
        should_redraw = section.delete_element(element_pos)
      when "layout"
        section.exhibit_elements[element_pos-1].change_layout(params[:type])
      end

      # We need to get the records again because the local variables are probably stale.
      if should_redraw
        render :partial => 'edit_exhibit_section', :locals => { :section => ExhibitSection.find(section_id), :page => ExhibitPage.find(page_id), :element_count => 1 }
      else
        render :text => ""
      end
    end
    
    def edit_row_of_illustrations
      element_id = params[:element_id]
      pos = params[:position].to_i
      element = ExhibitElement.find(element_id)
      verb = params[:verb]

      case verb
      when "left"
        element.exhibit_illustrations[pos-1].move_higher()
      when "right"
        element.exhibit_illustrations[pos-1].move_lower()
      when "delete"
        element.exhibit_illustrations[pos-1].remove_from_list()
        element.exhibit_illustrations[pos-1].destroy
       end

      # We need to get the records again because the local variables are probably stale.
      render :partial => 'edit_exhibit_element', :locals => { :element => ExhibitElement.find(element_id) } 
    end
    
    def insert_illustration
      element_id = params[:element_id]
      pos = params[:position].to_i
      element = ExhibitElement.find(element_id)
      if pos == -1
        pos = element.exhibit_illustrations.length+1
      end

      ExhibitIllustration.factory(element_id, pos)

      render :partial => 'edit_exhibit_element', :locals => { :element => ExhibitElement.find(element_id) } 
    end
    
    def change_element_type
      element_id = params[:element_id]
      type = params[:type]
      element = ExhibitElement.find(element_id)
      element.exhibit_element_layout_type = type
      element.save
      # if we are just creating an element that takes an illustration, then create the illustration, too.
      if (type == 'pic_text' || type == 'text_pic') && element.exhibit_illustrations.length == 0
        ExhibitIllustration.factory(element_id, 1)
      end
      render :partial => 'edit_exhibit_element', :locals => { :element => element } 
    end
    
    def redraw_exhibit_page
      page_id = params[:page]
      render :partial => 'edit_exhibit_page', :locals => { :page => ExhibitPage.find(page_id) }
    end
    
    def edit_text
      element = params['element_id']
      arr = element.split('_')
      element_id = arr[arr.length-1].to_i
      
      value = params['value']
      element = ExhibitElement.find(element_id)
      element.element_text = value
      element.save
      
      render :partial => 'edit_exhibit_element', :locals => { :element => element } 
    end
    
    def edit_header
      element = params['element_id']
      arr = element.split('_')
      element_id = arr[arr.length-1].to_i
      
      value = params['value']
      element = ExhibitElement.find(element_id)
      element.element_text = value
      element.save
      render :partial => 'edit_exhibit_element', :locals => { :element => element } 
    end
    
    def change_img_width
      element_id = params['element_id']
      illustration = params['illustration_id']
      arr = illustration.split('_')
      illustration_id = arr[arr.length-1].to_i
      width = params['width'].to_i
      if illustration_id <= 0
        illustration = ExhibitIllustration.factory(element_id, 1)
      else
        illustration = ExhibitIllustration.find(illustration_id)
      end
      illustration.image_width = width
      illustration.save
     render :partial => 'edit_exhibit_element', :locals => { :element => ExhibitElement.find(element_id) } 
    end
    
    def edit_illustration
      illustration = params['ill_illustration_id']
      arr = illustration.split('_')
      illustration_id = arr[arr.length-1].to_i
      image_url = params['image_url']
      type = params['type']
      link = params['link_url']
      width = params['ill_width']
      caption1 = params['caption1']
      caption2 = params['caption2']
      text = params['ill_text']
      alt_text = params['alt_text']

      illustration = ExhibitIllustration.find(illustration_id)
      illustration.illustration_type = type
      illustration.image_url = image_url
      illustration.illustration_text = text
      illustration.caption1 = caption1
      illustration.caption2 = caption2
      illustration.image_width = width if width != nil
      illustration.link = link
      illustration.alt_text = alt_text
      illustration.save

      element_id = illustration.exhibit_element_id
      element = ExhibitElement.find(element_id)
      render :partial => 'edit_exhibit_element', :locals => { :element => element } 
    end
    
    def modify_outline
      exhibit_id = params['exhibit_id']
      element_id = params['element_id']
      verb = params['verb']
      
      exhibit = Exhibit.find(exhibit_id)
      element = ExhibitElement.find(element_id)
      section = ExhibitSection.find(element.exhibit_section_id)
      page = ExhibitPage.find(section.exhibit_page_id)
      is_editing_border = false
      
      case verb
      when "insert_element"
        section.insert_element(element.position)
      when "move_element_up"
        section.move_element_up(element.position)
      when "move_element_down"
        section.move_element_down(element.position)
      when "delete_element"
        section.delete_element(element.position)
        element_id = -1

      when "insert_border"
        page.insert_border(section)
      when "move_top_of_border_up"
        page.move_top_of_border_up(section)
        is_editing_border = true
      when "move_top_of_border_down"
        page.move_top_of_border_down(section)
        is_editing_border = true
      when "move_bottom_of_border_up"
        page.move_bottom_of_border_up(section)
        is_editing_border = true
      when "move_bottom_of_border_down"
        page.move_bottom_of_border_down(section)
        is_editing_border = true
      when "delete_border"
        page.delete_border(section)
  
      when "insert_page"
        exhibit.insert_page(page.position)
      end
      
      render :partial => 'exhibit_outline', :locals => { :exhibit => Exhibit.find(exhibit_id), :element_id_selected => element_id, :is_editing_border => is_editing_border }
    end
    
    def modify_outline_page
      exhibit_id = params['exhibit_id']
      page_num = params['page_num'].to_i
      verb = params['verb']
      element_id = params['element_id']
     
      exhibit = Exhibit.find(exhibit_id)
      
      case verb
      when "move_page_up"
        exhibit.move_page_up(page_num)
      when "move_page_down"
        exhibit.move_page_down(page_num)
      when "delete_page"
        exhibit.delete_page(page_num)
        element_id = -1
      end
      
      render :partial => 'exhibit_outline', :locals => { :exhibit => Exhibit.find(exhibit_id), :element_id_selected => element_id, :is_editing_border => false  }
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
