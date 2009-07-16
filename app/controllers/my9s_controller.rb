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
require 'json'

class My9sController < ApplicationController
  layout 'nines'
  before_filter :init_view_options

  # Number of search results to display by default
  MIN_ITEMS_PER_PAGE = 10
  MAX_ITEMS_PER_PAGE = 30

  private
  def init_view_options
    @use_tabs = true
    @use_signin= true
    @site_section = :my9s
    @uses_yui = true
    return true
  end

  def get_user(session)
    return session[:user] ? User.find_by_username(session[:user][:username]) : nil
  end

  def can_edit_exhibit(user, exhibit_id)
    return false if user == nil
    return false if exhibit_id == nil
    return true if is_admin?
    exhibit = Exhibit.find(exhibit_id)
    return exhibit.user_id == user.id
  end

  def get_exhibit_id_from_element(element)
    return nil if element == nil || element == 0
    page = ExhibitPage.find(element.exhibit_page_id)
    return page.exhibit_id
  end

  public

  def index
    user = get_user(session)
    if user == nil
      return
    end

    set_cloud_list(user, user.username)

    @results = CachedResource.get_newest_collections(user, 5)
    more_results = CachedResource.get_newest_collections(user, 6)
    @has_more = @results.length < more_results.length
  end

  def results
    # parameters:
    #  :view => 'all_collected', 'untagged', 'tag' (show all collected objects, show all untagged objects, show a single tag)
    #  :tag => 'tag_name' (if :view => 'tag', then this is the particular tag to show)

    user = get_user(session)
    if user == nil
      return
    end

    session[:tag_zoom] ||= 1
    #do the pagination.
    @page = params[:page] ? params[:page].to_i : 1
    session[:items_per_page] ||= MIN_ITEMS_PER_PAGE
    
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

    set_cloud_list(user, user.username)
    
    # This creates an array of hits. Hits is a hash with these members: uri, text, title[0], archive, date_label[...], url[0], role_*[...], genre[...], source[...], alternative[...], license
    case params[:view]
      when 'all_collected'
      ret = CachedResource.get_page_of_hits_by_user(user, @page-1, session[:items_per_page])
      @results = ret[:results]
      @total_hits = ret[:total]

      when 'untagged'
      ret = CachedResource.get_page_of_all_untagged(user, @page-1, session[:items_per_page])
      @results = ret[:results]
      @total_hits = ret[:total]

      when 'tag'
      ret = CachedResource.get_page_of_hits_for_tag(params[:tag], user, @page-1, session[:items_per_page])
      @results = ret[:results]
      @total_hits = ret[:total]

    else
      @results = {}
      @total_hits = @results.length
    end

    @num_pages = @total_hits.quo(session[:items_per_page]).ceil
  end

  # adjust the number of search results per page
  def result_count
    session[:items_per_page] ||= MIN_ITEMS_PER_PAGE
    requested_items_per_page = params['search'] ? params['search']['result_count'].to_i : session[:items_per_page] 
    session[:items_per_page] = (requested_items_per_page <= MAX_ITEMS_PER_PAGE) ? requested_items_per_page : MAX_ITEMS_PER_PAGE
    redirect_to :action => 'results'
  end

  # This is called from AJAX to display the edit profile form in place.
#  def enter_edit_profile_mode
#    user = get_user(session)
#    if (user == nil)  # in case the session times out while the page is displayed. This page expects a user to be logged in.
#      render :text => "You must be logged in to perform this function. Did your session time out due to inactivity?"
#      return
#    end
#
#    render :partial => 'profile', :locals => { :user => user, :edit_mode => true }
#  end

	# This is called from AJAX when a user's link has been clicked.
	def show_profile
		user_id = params[:user]
		render :partial => '/my9s/profile', :locals => { :user => User.find(user_id), :can_edit => false }
	end

  # This is called from AJAX when the user has finished filling out the form.
  def update_profile
    user = get_user(session)
    if (user == nil)  # in case the session times out while the page is displayed. This page expects a user to be logged in.
      render :text => "You must be logged in to perform this function. Did your session time out due to inactivity?", :status => :bad_request
      return
    end

    if params[:account_email] !~ /\@/
      render :text => "An e-mail address is required", :status => :bad_request
      return
    end
    if params[:account_password] != params[:account_password2]
      render :text => "Passwords do not match", :status => :bad_request
      return
    end
    user.institution = params['institution']
    user.fullname = params['fullname']
    user.link = params['link']
    user.about_me = params['aboutme']
    #check the link for a javascript attack
    if user.link.downcase.index("javascript:") != nil
      user.link = "invalid link entered"
    end
    user.save

    session[:user] = COLLEX_MANAGER.update_user(session[:user][:username], params[:account_password].strip, params[:account_email])

    render :partial => 'profile', :locals => { :user => user, :can_edit => true }
  end

  # The file upload is done in a separate call because of ajax limitations.
  def update_profile_upload
    user = get_user(session)
    if params['image'] && params['image'].length > 0
      user.image = Image.new({ :uploaded_data => params['image'] })
      user.image.save!
      user.save
    end
#    old_image = nil
#    if params['image'] != nil && params['image'].length > 0
#      old_image = user.image_id
#      user.image = Image.new({ :uploaded_data => params['image'] })
#      user.image.save!
#    end

      # now we need to figure out what happened with the attachment.
      # If there was an error image_id is set to nil, and we want to reset it to the previous image.
      # If there was no error, and there was a previous image, then we want to delete the previous one from the file system.
#      if old_image != nil
#        if user.image_id == nil
#          user.image = nil
#          user.update_attribute(:image_id, old_image) 
#        else
#          id = old_image.to_s.rjust(4, '0')
#          folder = "#{RAILS_ROOT}/public/uploads/0000/#{id}/"
#          d = Dir.new(folder)
#          d.each {|f|
#            if f != '.' && f != '..'
#              File.delete(folder + f)
#            end
#          }
#          Dir.delete(folder)
#        end
#      end
    #      if params['image'].length > 0
    #        folder = "#{RAILS_ROOT}/public/images/users/"
    #        image_path = "#{folder}#{user.id}"
    #        Dir.mkdir(folder) unless File.exists?(folder)
    #        File.open(image_path, "wb") { |f| f.write(params['image'].read) }
    #      end
    render :text => "<script type='text/javascript'>window.top.window.stopUpload();</script>"  # This is loaded in the iframe and tells the dialog that the upload is complete.
  end

  def remove_saved_search
    user = get_user(session)
    if (user != nil)
      searches = user.searches
      saved_search = searches.find(params[:id])

      saved_search.destroy
    end

    redirect_to :action => 'index'
  end

  def verify_title  # Called by the "new exhibit" wizard
    title = params[:title]
    user = get_user(session)
    if user == nil
      render :text => 'Your session has timed out due to inactivity. Please login again to create an exhibit', :status => :bad_request
    else
      exhibit = Exhibit.find(:first, :conditions => ['user_id = ? AND title = ?', user.id, title])
      if (exhibit != nil)
        render :text => 'You already have an exhibit by that name. Please choose another.', :status => :bad_request
      else
        # The name is ok. Now create a url.
        url = Exhibit.transform_url(title)
        
        render :text => url
      end
    end
  end

  def create_exhibit # Called by the "new exhibit" wizard
    exhibit_url = params[:exhibit_url]
    visible_url = Exhibit.transform_url(exhibit_url)
    exhibit_title = params[:exhibit_title]
    exhibit_thumbnail = params[:exhibit_thumbnail]
    objects = params[:objects].split("\t")
    user = get_user(session)
    if user == nil
      render :text => 'Your session has timed out due to inactivity. Please login again to create an exhibit', :status => :bad_request
    else
      ex = Exhibit.find_by_visible_url(visible_url)
      if ex != nil
        render :text => "There is already an exhibit in NINES with the url \"#{exhibit_url}\". Please choose another.", :status => :bad_request
      else
        exhibit = Exhibit.factory(user.id, visible_url, exhibit_title, exhibit_thumbnail)
        ExhibitObject.set_objects(exhibit.id, objects)
        render :text => "#{exhibit.id}"
      end
    end
  end

  def edit_exhibit
    exhibit_id = params[:id]
    user = get_user(session)
    if can_edit_exhibit(user, exhibit_id)
      @exhibit = Exhibit.find(exhibit_id)
      @page = params['page'] == nil ? 1 : params['page'].to_i
      num_pages = @exhibit.exhibit_pages.length
      @page = num_pages if @page > num_pages
    else
      redirect_to :action => 'index'
    end
  end

  def edit_exhibit_overview
    exhibit_id = params[:exhibit_id]
    user = get_user(session)
    exhibit = Exhibit.find(exhibit_id)
    if can_edit_exhibit(user, exhibit_id)
      exhibit.title = params[:overview_title_dlg]
      exhibit.thumbnail = params[:overview_thumbnail_dlg]
      exhibit.visible_url = Exhibit.transform_url(params[:overview_visible_url_dlg])
      exhibit.save
    end
    render :partial => 'overview_data', :locals => { :exhibit => exhibit, :show_immediately => true }
  end

  def update_title # ajax call after title changes to display it on the page
    render :text => params[:overview_title_dlg]
  end

  def change_sharing
    exhibit_id = params[:exhibit_id]
    user = get_user(session)
    exhibit = Exhibit.find(exhibit_id)
    if can_edit_exhibit(user, exhibit_id)
      sharing_level = params[:sharing]
      exhibit.set_sharing(sharing_level)
      exhibit.save
    end
    render :partial => 'overview_data', :locals => { :exhibit => exhibit, :show_immediately => true }
  end

  def delete_exhibit
    # for security reasons, make sure that the exhibit belongs to the person who is trying to delete it.
    exhibit_id = params[:id]
    user = get_user(session)
    exhibit = Exhibit.find(exhibit_id)
    if can_edit_exhibit(user, exhibit_id)
      Exhibit.destroy(exhibit_id)
    end

    redirect_to :action => 'index'
  end

  def change_page
    exhibit_id = params[:id]
    user = get_user(session)
    if can_edit_exhibit(user, exhibit_id)
      redirect_to :action => 'edit_exhibit', :id => params['id'], :page => params['page']
    else
      redirect_to :action => 'index'
    end
  end

  def edit_element
    page_id = params[:page].to_i
    element_pos = params[:element].to_i
    verb = params[:verb]

    page = ExhibitPage.find_by_id(page_id)
    exhibit_id = page ? page.exhibit_id : nil
    user = get_user(session)
    if can_edit_exhibit(user, exhibit_id)
      case verb
        when "up"
        page.move_element_up(element_pos)
        when "down"
        page.move_element_down(element_pos)
        when "insert"
        page.insert_element(element_pos+1)
        when "delete"
        page.delete_element(element_pos)
        when "layout"
        page.exhibit_elements[element_pos-1].change_layout(params[:type])
      end
    end

    # We need to get the records again because the local variables are probably stale.
    if page == nil
      render :text =>'Error in editing section. Please refresh your browser page.'
    else
      render :partial => '/exhibits/exhibit_page', :locals => { :exhibit => Exhibit.find(page.exhibit_id), :page_num => page.position, :is_edit_mode => true, :top => nil }
    end
  end

  def edit_row_of_illustrations
    element_id = params[:element_id]
    pos = params[:position].to_i
    element = ExhibitElement.find_by_id(element_id)
    verb = params[:verb]
    user = get_user(session)
    if can_edit_exhibit(user, get_exhibit_id_from_element(element))
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
      element = ExhibitElement.find(element_id)
    end
    if element == nil
      render :text =>'Error in editing section. Please refresh your browser page.'
    else
      render :partial => '/exhibits/exhibit_section', :locals => { :element => element, :is_edit_mode => true, :element_count => element.position }
    end
  end

  def insert_illustration
    element_id = params[:element_id]
    pos = params[:position].to_i
    element = ExhibitElement.find_by_id(element_id)
    user = get_user(session)
    if can_edit_exhibit(user, get_exhibit_id_from_element(element))
      if pos == -1
        pos = element.exhibit_illustrations.length+1
      end

      ExhibitIllustration.factory(element_id, pos)

      # We need to get the records again because the local variables are probably stale.
      element = ExhibitElement.find(element_id)
    end
    if element == nil
      render :text =>'Error in editing section. Please refresh your browser page.'
    else
      render :partial => '/exhibits/exhibit_section', :locals => { :element => element, :is_edit_mode => true, :element_count => element.position }
    end
  end

  def change_element_type
    element_id = params[:element_id]
    type = params[:type]
    element = ExhibitElement.find(element_id)
    user = get_user(session)
    if can_edit_exhibit(user, get_exhibit_id_from_element(element))
      element.exhibit_element_layout_type = type
      element.save
      # if we are just creating an element that takes an illustration, then create the illustration, too.
      if (type == 'pic_text' || type == 'text_pic' || type == 'text_pic_text' || type == 'pic_text_pic') && element.exhibit_illustrations.length == 0
        ExhibitIllustration.factory(element_id, 1)
      end
      if (type == 'pic_text_pic') && element.exhibit_illustrations.length < 2
        ExhibitIllustration.factory(element_id, 2)
      end
      render :partial => '/exhibits/exhibit_section', :locals => { :element => ExhibitElement.find(element_id), :is_edit_mode => true, :element_count => element.position } 
    else
      render :text => 'Your session has timed out due to inactivity. Please login again.'
     end
  end

  def change_illustration_justification
    element_id = params[:element_id]
    justify = params[:justify]
    element = ExhibitElement.find_by_id(element_id)
    user = get_user(session)
    if can_edit_exhibit(user, get_exhibit_id_from_element(element))
      element.set_justification(justify)
      element.save
    end
    if element == nil
      render :text =>'Error in editing section. Please refresh your browser page.'
    else
      render :partial => '/exhibits/exhibit_section', :locals => { :element => element, :is_edit_mode => true, :element_count => element.position }
    end
  end

  def reset_exhibit_page_from_outline
    page_num = params[:page_num].to_i
    exhibit_id = params[:exhibit_id]
    exhibit = Exhibit.find_by_id(exhibit_id)
    if exhibit
      num_pages = exhibit.exhibit_pages.length
      page_num = num_pages if page_num > num_pages
    end
    if exhibit == nil || page_num == 0
      render :text => "[Empty Exhibit]"
    else
      render :partial => '/exhibits/exhibit_page', :locals => { :exhibit => exhibit, :page_num => page_num, :is_edit_mode => true, :top => nil }
    end
  end
  
  def redraw_exhibit_page  # This is called for a number of different ajax actions to update the view.
    page_id = params[:page]
    if page_id == nil
      id = params[:element_id]
      if id != nil  # something probably timed out if this happens
        element = ExhibitElement.find(id)
        page_id = element.exhibit_page_id
      end
    end
    if page_id != nil
      page = ExhibitPage.find_by_id(page_id)
      if page == nil
        render :text =>'Error in editing section. Please refresh your browser page.'
      else
        render :partial => '/exhibits/exhibit_page', :locals => { :exhibit => Exhibit.find(page.exhibit_id), :page_num => page.position, :is_edit_mode => true, :top => nil }
      end
    else
      render :text => 'Your session has timed out due to inactivity. Please login again.'
    end
  end

  def edit_text
    element = params['element_id']
    arr = element.split('_')
    last_str = arr[arr.length-1]
    first_one = true
    if last_str == 'left'
      element_id = arr[arr.length-2].to_i
    elsif last_str == 'right'
      element_id = arr[arr.length-2].to_i
      first_one = false
    else
      element_id = last_str.to_i
    end
		footnotes = JSON.parse(params['footnotes'])

    element = ExhibitElement.find_by_id(element_id)
    user = get_user(session)
    if can_edit_exhibit(user, get_exhibit_id_from_element(element))
      value = params['value']
      value = clean_up_links(value)
      value = remove_empty_spans(value)
			value = add_footnotes(value, footnotes)
      if first_one
        element.element_text = value
      else
        element.element_text2 = value
      end
      element.save
    end
    if element == nil
      render :text =>'Error in editing section. Please refresh your browser page.'
    else
      render :partial => '/exhibits/exhibit_section', :locals => { :element => element, :is_edit_mode => true, :element_count => element.position } 
    end
  end

  def edit_header
    element = params['element_id']
    arr = element.split('_')
    element_id = arr[arr.length-1].to_i
		footnote = params['footnote']

    value = params['value']
    element = ExhibitElement.find_by_id(element_id)
    user = get_user(session)
    if can_edit_exhibit(user, get_exhibit_id_from_element(element))
      element.element_text = value
			element.set_header_footnote(footnote)
      element.save
    end
    if element == nil
      render :text =>'Error in editing section. Please refresh your browser page.'
    else
      render :partial => '/exhibits/exhibit_section', :locals => { :element => element, :is_edit_mode => true, :element_count => element.position }
    end
  end

  def change_img_width
    illustration = params['illustration_id']
    arr = illustration.split('_')
    illustration_id = arr[arr.length-1].to_i
    width = params['width'].to_i
    height = params['height'].to_i
    illustration = ExhibitIllustration.find_by_id(illustration_id)
    if illustration != nil
      element_id = illustration.exhibit_element_id
      element = ExhibitElement.find(element_id)
      user = get_user(session)
      if can_edit_exhibit(user, get_exhibit_id_from_element(element))
        illustration.image_width = width
        illustration.height = height if illustration.illustration_type == ExhibitIllustration.get_illustration_type_text()
        illustration.save
        element = ExhibitElement.find(element_id)
      end
    end
    if illustration == nil
      render :text =>'Error in editing section. Please refresh your browser page.'
    else
      render :partial => '/exhibits/exhibit_section', :locals => { :element => element, :is_edit_mode => true, :element_count => element.position }
    end
  end

  def edit_illustration
    illustration = params['ill_illustration_id']
    arr = illustration.split('_')
    illustration_id = arr[arr.length-1].to_i
    image_url = params['image_url']
    type = params['type']
    link = params['link_url']
    caption1 = params['caption1']
    caption2 = params['caption2']
    caption1_footnote = params['caption1_footnote']
    caption2_footnote = params['caption2_footnote']
    text = params['ill_text']
    alt_text = params['alt_text']
    nines_object = params['nines_object']
		footnotes = JSON.parse(params['footnotes'])

    illustration = ExhibitIllustration.find_by_id(illustration_id)
    if illustration != nil
      element_id = illustration.exhibit_element_id
      element = ExhibitElement.find(element_id)
      user = get_user(session)
      if can_edit_exhibit(user, get_exhibit_id_from_element(element))
        illustration.illustration_type = type
        illustration.image_url = image_url
				text = add_footnotes(text, footnotes)
        illustration.illustration_text = text
        illustration.caption1 = caption1
        illustration.caption2 = caption2
        illustration.link = link
        illustration.alt_text = alt_text
        illustration.nines_object_uri = nines_object
				illustration.set_caption_footnote(caption1_footnote, 'caption1_footnote_id')
				illustration.set_caption_footnote(caption2_footnote, 'caption2_footnote_id')
        illustration.save
  
        element_id = illustration.exhibit_element_id
        element = ExhibitElement.find(element_id)
      end
    end
    if illustration == nil
      render :text =>'Error in editing section. Please refresh your browser page.'
    else
      render :partial => '/exhibits/exhibit_section', :locals => { :element => element, :is_edit_mode => true, :element_count => element.position }
    end
  end

  def modify_border
    element_id = params['element_id']
    borders = params['borders']

    element = ExhibitElement.find(element_id)
    page = ExhibitPage.find(element.exhibit_page_id)
    exhibit_id = page.exhibit_id

    user = get_user(session)
    if can_edit_exhibit(user, exhibit_id)
      arr = borders.split(',')
      if arr.length == page.exhibit_elements.length
        0.upto(arr.length-1) do |i|
          page.exhibit_elements[i].set_border_type(arr[i])
        end
      end
    end

    render :partial => 'exhibit_outline', :locals => { :exhibit => Exhibit.find(exhibit_id), :element_id_selected => element_id, :is_editing_border => false }
  end

  def modify_outline
    exhibit_id = params['exhibit_id']
    element_id = params['element_id']
    verb = params['verb']

    exhibit = Exhibit.find(exhibit_id)
    element = ExhibitElement.find(element_id)
    page = ExhibitPage.find(element.exhibit_page_id)
    is_editing_border = false

    user = get_user(session)
    if can_edit_exhibit(user, exhibit_id)
      case verb
        when "insert_element"
        new_element = page.insert_element(element.position+1)
        element_id = new_element.id
        when "move_element_up"
        page.move_element_up(element.position)
        when "move_element_down"
        page.move_element_down(element.position)
        when "delete_element"
        page.delete_element(element.position)
        element_id = -1

        when "insert_page"
        exhibit.insert_page(page.position+1)
      end
    end

    render :partial => 'exhibit_outline', :locals => { :exhibit => Exhibit.find(exhibit_id), :element_id_selected => element_id, :is_editing_border => is_editing_border }
  end

  def modify_outline_add_first_element
    page_id = params[:page]
    page = ExhibitPage.find(page_id)
    exhibit_id = page.exhibit_id
    is_editing_border = false

    user = get_user(session)
    if can_edit_exhibit(user, exhibit_id)
      new_element = page.insert_element(1)
      element_id = new_element.id
    end

    render :partial => 'exhibit_outline', :locals => { :exhibit => Exhibit.find(exhibit_id), :element_id_selected => element_id, :is_editing_border => is_editing_border }
  end

  def refresh_outline
    element_div_id = params['element_id']
    if element_div_id != nil
      arr = element_div_id.split('_')
      last_str = arr[arr.length-1]
      if last_str == 'left'
        id_num = arr[arr.length-2].to_i
      elsif last_str == 'right'
        id_num = arr[arr.length-2].to_i
      else
        id_num = last_str.to_i
      end
      if arr[0] == 'illustration'
        exhibit = Exhibit.find_by_illustration_id(id_num)
        element_id = ExhibitIllustration.find(id_num).exhibit_element_id if exhibit != nil
      else
        exhibit = Exhibit.find_by_element_id(id_num)
        element_id = id_num
      end
    else
      # We were passed a page id
      page = ExhibitPage.find_by_id(params[:page])
      element_pos = params[:element].to_i
      exhibit = page ? Exhibit.find(page.exhibit_id) : nil

      if page
        element_pos = element_pos - 1
        if element_pos < 0 || element_pos >= page.exhibit_elements.length
          element_pos = 0
        end
        element_id = page.exhibit_elements[element_pos-1].id
      end
    end

    if exhibit == nil
      render :text => "Error in displaying the outline. Please refresh your browser."
    else
      render :partial => 'exhibit_outline', :locals => { :exhibit => exhibit, :element_id_selected => element_id, :is_editing_border => false }
    end
  end

  def find_page_containing_element
    div_id = params[:element]
    arr = div_id.split('-')
    el_num = arr[arr.length-1].to_i
    element = ExhibitElement.find(el_num)
    page = ExhibitPage.find(element.exhibit_page_id)

    render :partial => '/exhibits/exhibit_page', :locals => { :exhibit => Exhibit.find(page.exhibit_id), :page_num => page.position, :is_edit_mode => true, :top => el_num }
  end

  def resend_exhibited_objects
    # This is to update the section after a change elsewhere on the page
    render :partial => 'exhibited_objects', :locals => { :current_user_id => user.id }
  end

  def remove_exhibited_object
    user = get_user(session)
    uri = params[:uri]
    exhibit_id = params[:exhibit_id]
    if can_edit_exhibit(user, exhibit_id)
      obj = ExhibitObject.find(:first, :conditions => ["uri = ? AND exhibit_id = ?", uri, exhibit_id ] )
      obj.destroy if obj
    end

    render :partial => 'exhibited_objects', :locals => { :current_user_id => user.id }
  end

#  def get_all_collected_objects # called when creating a new exhibit
#    user = get_user(session)
#    exhibit_id = params[:exhibit_id]
#    if user != nil
#      obj = CollectedItem.get_collected_object_ruby_array(user.id)
#      selected = ExhibitObject.find_all_by_exhibit_id(exhibit_id)
#      obj.each { |o|
#        uri = o[:uri]
#        i = selected.detect {|sel|
#          sel[:uri] == uri
#        }
#        o[:chosen] = i == nil ? false : true
#      }
#
#      str = obj.to_json()
#      render :text => str
#    else
#      render :text => 'Your session has timed out due to inactivity. Please login again to create an exhibit', :status => :bad_request
#    end
#  end

  def get_all_collected_objects
    chosen = params[:chosen]
    exhibit_id = params[:exhibit_id]
    ret = []
    user = session[:user] ? User.find_by_username(session[:user][:username]) : nil
    if user
      selected = ExhibitObject.find_all_by_exhibit_id(exhibit_id)
      objs = CollectedItem.all(:conditions => [ "user_id = ?", user.id ])
      objs.each {|obj|
        hit = CachedResource.get_hit_from_resource_id(obj.cached_resource_id)
        if hit != nil
          uri = hit['uri']
          i = selected.detect {|sel|
            sel[:uri] == uri
          }
          if (i == nil && chosen == 'false') || (i != nil && chosen == 'true')  # i is nil if the object is not chosen
            image = CachedResource.get_thumbnail_from_hit(hit)
            image = DEFAULT_THUMBNAIL_IMAGE_PATH if image == "" || image == nil
            obj = {}
            obj[:id] = hit['uri']
            obj[:img] = image
            obj[:title] = CachedResource.fix_char_set(hit['title'][0])
            obj[:strFirstLine] = CachedResource.fix_char_set(hit['title'][0])
            obj[:strSecondLine] = hit['role_AUT'] ? hit['role_AUT'].join(', ') : hit['role_ART'] ? hit['role_ART'].join(', ') : ''
            ret.push(obj)
          end # should we include this?
        end # does the hit exist?
      } # for each object
      render :text => ret.to_json()
    else # not logged in
      render :text => 'Your session has timed out due to inactivity. Please login again to create an exhibit', :status => :bad_request
    end
  end

  def update_objects_in_exhibits
    exhibit_id = params[:exhibit_id]
    user = get_user(session)
    if can_edit_exhibit(user, exhibit_id)
      objects = params[:objects].split("\t")
      ExhibitObject.set_objects(exhibit_id, objects)
    end
    render :partial => 'exhibit_palette', :locals => { :exhibit => Exhibit.find(exhibit_id) }

  end

  def get_all_users
    ret = []
    if is_admin? # only allow adminstrators to call this
      # this returns a json object of all the users and their ids
      users = User.find(:all)
      users.each {|user|
        # On IE, there are lots of characters that cause the json to be illegal. We'll just replace most weird characters just in case.
        ret.push({ :value => user.id, :text => user.fullname.gsub(/[^-'a-zA-Z0-9_. ]/, "*") })
      }
    end
    render :text => ret.to_json()
  end

  def set_exhibit_author_alias
    exhibit_id = params[:exhibit_id]
    user_id = params[:user_id]
    page_num = params[:page_num].to_i
    user = get_user(session)
    exhibit = Exhibit.find(exhibit_id)
    if user_id.to_i > 0 && can_edit_exhibit(user, exhibit_id)
      exhibit.alias_id = user_id
      exhibit.save
    end
    render :partial => '/exhibits/exhibit_page', :locals => { :exhibit => exhibit, :page_num => page_num, :is_edit_mode => true, :top => nil }
  end

  def modify_outline_page
    exhibit_id = params['exhibit_id']
    page_num = params['page_num'].to_i
    verb = params['verb']
    element_id = params['element_id']

    exhibit = Exhibit.find(exhibit_id)

    user = get_user(session)
    if can_edit_exhibit(user, exhibit_id)
      case verb
        when "move_page_up"
        exhibit.move_page_up(page_num)
        when "move_page_down"
        exhibit.move_page_down(page_num)
        when "delete_page"
        exhibit.delete_page(page_num)
        element_id = -1
      end
    end

    render :partial => 'exhibit_outline', :locals => { :exhibit => Exhibit.find(exhibit_id), :element_id_selected => element_id, :is_editing_border => false  }
  end
  
  def get_object_details
    hit = CachedResource.get_hit_from_uri(params[:uri])
    render :partial => '/results/result_row_for_popup', :locals => { :hit => hit, :extra_button_data => { :partial => params[:partial], :index => params[:index], :target_el  => params[:target_el]} }
  end

  private
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

  def clean_up_links(text)
    # This converts any <a href="xxx">yyy</a> to
    #<span class="ext_linklike" real_link="xxx" title="External Link: xxx">yyy</span>
    # find all the spans
    a_str = '<a'
    arr = text.split(a_str)
    return text if arr.length == 1

    str = arr[0]  # the first element has everything before the first span, so we just start with that.
    is_first = true
    for a in arr
      if is_first
        is_first = false  # skip the first section since we dealt with it above.
      else
        url = extract_link_from_encoded_a(a)
        visible_text = extract_inner_html(a)
        rest_of_it = extract_trailing_html(a)
        str += "<span class='ext_linklike' real_link=\"#{url}\" title=\"External Link: #{url}\">#{visible_text}</span>#{rest_of_it}"
      end
    end
    return str
  end

  def remove_empty_spans(text)
    # we are looking for "<span...></span>"
    return "" if text == nil || text == ""
    text = text.gsub(/<span[^>]*><\/span>/, '')
    #    text = text.gsub(/<span>.*<\/span>/) { |s|
    #      str = s[6, s.length-13]
    #      puts "Replacement: " + str
    #      return str
    #    }
    return text
  end

	def get_footnote_from_num(footnotes, index)
		footnotes.each {|f|
			return f['value'] if f['field'] == "footnotes_#{index}"
		}
		return ""
	end

	def add_footnotes(text, footnotes)
		# This takes a set of text in the form: "...<span id="footnote_index_1" class="superscript">1</span>..."
		# and an array where each item is { key: "footnote_index_1", value: "whatever" }
		# They should match up, but that is not guaranteed. Where they match up, they should be changed to:
		# <a href="#" onclick='var footnote = $(this).next(); new MessageBoxDlg("Footnote", footnote.innerHTML); return false;' class="superscript">2</a><span class="hidden">contents of the footnote</span>
		marker_text_start = '<span id="footnote_index_'
		replacement_text_template = '<a href="#" onclick=\'var footnote = $(this).next(); new MessageBoxDlg("Footnote", footnote.innerHTML); return false;\' class="superscript">@</a><span class="hidden">%FOOTNOTE%</span>'
		text_arr = text.split(marker_text_start)
		return text if text_arr.length == 1
		1.upto(text_arr.length-1) do |i|
			# each of these starts with 999">999</span>.
			# The first number is important: it is the index into the footnotes array.
			index = text_arr[i].to_i
			arr = text_arr[i].split('</span>', 2)
			postfix = arr[1]
			foot = get_footnote_from_num(footnotes, index)
			text_arr[i] = replacement_text_template.gsub("%FOOTNOTE%", foot) + postfix
		end
		return text_arr.join('')
	end

  # Some private convenience functions to make the above routine clearer
  def extract_link_from_encoded_a(str)
    el= str.split('>', 2)  # find the end of the opening part of the span tag.
    arr = el[0].split('href=', 2)
    return "" if arr.length < 2
    quote = arr[1][0,1]
    arr2 = arr[1].split(quote)
    return arr2[1]
  end

  def extract_inner_html(str)
    el = str.split('>', 2)  # find the end of the opening part of the span tag.
    return "" if el.length < 2

    el2 = el[1].split('</a>')
    return "" if el2.length < 2

    return el2[0]
  end

  def extract_trailing_html(str)
    el = str.split('</a>')
    return "" if el.length < 2

    return el[1]
  end
end
