class BuilderController < ApplicationController
	before_filter :init_view_options

	private
	def init_view_options
		@site_section = :my_collex
		return true
	end

	def get_exhibit_id_from_element(element)
		return nil if element == nil || element == 0
		page = ExhibitPage.find(element.exhibit_page_id)
		return page.exhibit_id
	end

  def clean_up_links(text)
    # This converts any <a href="xxx">yyy</a> to
    #<span class="ext_linklike" real_link="xxx" title="External Link: xxx">yyy</span>
		#However, it needs to ignore any footnotes, which also look like links.
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
				footnote_sig = "href=\"#\" onclick='return false; var footnote = $(this).next(); new MessageBoxDlg(\"Footnote\""
				if a.include?(footnote_sig)	# this is a footnote, keep it intact
					str += a_str + a.gsub("onclick='return false; var footnote = $(this).next();", "onclick='var footnote = $(this).next();")	# get rid of of the short circuit that keeps the footnote from popping up on the edit view.
				else
					url = extract_link_from_encoded_a(a)
					visible_text = extract_inner_html(a)
					rest_of_it = extract_trailing_html(a)
					str += "<span class='ext_linklike' real_link=\"#{url}\" title=\"External Link: #{url}\">#{visible_text}</span>#{rest_of_it}"
	      end
      end
    end
    return str
  end
  
  # Strip out word junk tags. Notably the comments and single space lines
  #
  def strip_word_tags( text )
    working_txt = text
    done = false
    until done
      pos = working_txt.index( "<!--")
      if pos
        pre_comment = working_txt[0...pos]
        work = working_txt[pos..-1]
        ep = work.index( "-->")
        if ep
          working_txt = pre_comment + work[(ep+3)..-1]  
        else
          # if we get stuck with a mismatched comment, just bail and
          # return the original source text
          logger.error "Found unterminated comment in exhibit element text when attempting to strip word tags."
          return text
        end
      else
        done = true  
      end
    end  
    
    # 2nd pass.. word leaves a one space line at the end of its mess. This causes trouble too, so
    # walk each line of the text and remove it if its just a  ' ' 
    final = ''
    working_txt.each_line do | line |
      final += line if line.strip.length > 0
    end
    return final  
  end

  def remove_empty_spans(text)
    # we are looking for "<span...></span>"
    return "" if text == nil || text == ""
    text = text.gsub(/<span[^>]*><\/span>/, '')

		# also, we are controlling the fonts, so we also need to get rid of any spurious font info that the user pasted in.
    text = text.gsub(/font-family:[^;]*;/, '')
    text = text.gsub(/font-size:[^;]*;/, '')
		# now there may be empty style attributes
		text = text.gsub('style=""', '')
		# Also, don't allow any preformatting that might have crept in.
		text = text.gsub('<pre>', '')
		text = text.gsub('</pre>', '')
    return text
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
	public

	def get_all_collected_objects
		chosen = params[:chosen]
		exhibit_id = params[:exhibit_id]
		ret = []
		if user_signed_in?
			objs = CollectedItem.get_collected_objects_for_thumbnails(get_curr_user_id, exhibit_id, chosen)
			objs.each {|key,hit|
				obj = {}
				obj[:id] = hit['uri']
				image = CachedResource.get_thumbnail_from_hit(hit)
				image = view_context.image_path(DEFAULT_THUMBNAIL_IMAGE_PATH) if image == "" || image == nil
				obj[:img] = image
				obj[:title] = hit['title']
				obj[:strFirstLine] = hit['title']
				obj[:strSecondLine] = hit['role_AUT'] ? hit['role_AUT'] : hit['role_ART'] ? hit['role_ART'] : ''
				ret.push(obj)
#			selected = ExhibitObject.find_all_by_exhibit_id(exhibit_id)
#			objs = CollectedItem.all(:conditions => [ "user_id = ?", user.id ])
#			objs.each {|obj|
#				hit = CachedResource.get_hit_from_resource_id(obj.cached_resource_id)
#				if hit != nil
#					uri = hit['uri']
#					i = selected.detect {|sel|
#						sel[:uri] == uri
#					}
#					if (i == nil && chosen == 'false') || (i != nil && chosen == 'true')  # i is nil if the object is not chosen
#						image = CachedResource.get_thumbnail_from_hit(hit)
#						image = DEFAULT_THUMBNAIL_IMAGE_PATH if image == "" || image == nil
#						obj = {}
#						obj[:id] = hit['uri']
#						obj[:img] = image
#						obj[:title] = hit['title'][0]
#						obj[:strFirstLine] = hit['title'][0]
#						obj[:strSecondLine] = hit['role_AUT'] ? hit['role_AUT'].join(', ') : hit['role_ART'] ? hit['role_ART'].join(', ') : ''
#						ret.push(obj)
#					end # should we include this?
#				end # does the hit exist?
			} # for each object
			render :text => ret.to_json()
		else # not logged in
			render :text => 'Your session has timed out due to inactivity. Please login again to create an exhibit', :status => :bad_request
		end
	end

	def verify_title  # Called by the "new exhibit" wizard
		title = params[:title]
		user = current_user
		if user == nil
			render :text => 'Your session has timed out due to inactivity. Please login again to create an exhibit', :status => :bad_request
		else
			exhibit = Exhibit.find_by_user_id_and_title(user.id, title)
			if (exhibit != nil)
				render :text => 'You already have an exhibit by that name. Please choose another.', :status => :bad_request
			else
				# The name is ok. Now create a url.
				url = Exhibit.transform_url(title)

				render :text => url
			end
		end
	end
	
	def update_fonts
		exhibit = Exhibit.find(params[:id])
		params[:exhibit].delete(:use_styles)
		exhibit.update_attributes(params[:exhibit])
		redirect_to :back
	end

	def edit_exhibit_overview
		exhibit_id = params[:exhibit_id]
		user = current_user
		exhibit = Exhibit.find(exhibit_id)
		if Exhibit.can_edit(user, exhibit_id)
			visible_url = Exhibit.transform_url(params[:overview_visible_url_dlg])
			short_name = params[:overview_resource_name_dlg]
			ex = visible_url.length == 0 ? nil : Exhibit.find_by_visible_url(visible_url)
			ex2 = short_name.length == 0 ? nil : Exhibit.find_by_resource_name(short_name)
			if ex != nil && ex.id != exhibit_id.to_i
				render :text => "There is already an exhibit in #{Setup.site_name()} with the url \"#{visible_url}\". Please choose another.", :status => :bad_request
			elsif ex2 != nil && ex2.id != exhibit_id.to_i
				render :text => "There is already an exhibit in #{Setup.site_name()} with the short name \"#{short_name}\". Please choose another.", :status => :bad_request
			else
				exhibit.title = params[:overview_title_dlg]
				exhibit.thumbnail = params[:overview_thumbnail_dlg]
				exhibit.thumbnail = nil if exhibit.thumbnail == "You have not added a thumbnail to this exhibit."
				exhibit.visible_url = visible_url
				exhibit.resource_name = short_name
				genres = []
				genre_list = params[:genre]
				genre_list.each { |key,val|
					if val == 'true'
						genres.push(key)
					end
				}
				exhibit.genres = genres.join(', ')
				disciplines = []
				discipline_list = params[:discipline]
				discipline_list.each { |key,val|
					if val == 'true'
						disciplines.push(key)
					end
				}
				exhibit.disciplines = disciplines.join(', ')
				exhibit.save
		    render :partial => 'overview_data', :locals => { :exhibit => exhibit, :show_immediately => true }
			end
		else
			render :partial => 'overview_data', :locals => { :exhibit => exhibit, :show_immediately => true }
		end
	end

	def update_title # ajax call after title changes to display it on the page
		render :text => params[:overview_title_dlg]
	end

	def change_exhibits_group
		id = params[:id]
		exhibit = Exhibit.find(id)
		group_id = params[:group]
		exhibit.group_id = group_id
		exhibit.cluster_id = nil
		if group_id.length > 0
			group = Group.find(group_id)
			if group.group_type == 'peer-reviewed'
				exhibit.is_published = 0
			end
		end

		exhibit.save
		redirect_to :back
		#render :partial => 'overview_data', :locals => { :exhibit => exhibit, :show_immediately => true }
	end

	def change_exhibits_cluster
		id = params[:id]
		exhibit = Exhibit.find(id)
		cluster_id = params[:cluster]
		exhibit.cluster_id = cluster_id

		exhibit.save
		redirect_to :back
		#render :partial => 'overview_data', :locals => { :exhibit => exhibit, :show_immediately => true }
	end

	def publish_exhibit
		id = params[:id]
		exhibit = Exhibit.find(id)
		state = params[:publish_state]
		exhibit.is_published = state
		exhibit.save
		if exhibit.is_published != 0 && exhibit.group_id && exhibit.group_id > 0
			group = Group.find_by_id(exhibit.group_id)
			user = current_user
			if group && user
				body = "#{user.fullname} has shared an exhibit \"#{exhibit.title}\" to the group #{group.name}.\n\n"
				exhibit_url = "#{url_for(:controller => 'exhibits')}/"
				if exhibit.visible_url && exhibit.visible_url.length > 0
				  exhibit_url += exhibit.visible_url
				else
				  exhibit_url += exhibit.id.to_s()
				end
				body += "Visit the group at #{url_for(:controller => 'groups', :action => 'show', :id => group.get_visible_id())}, or read the exhibit here: #{exhibit_url}\n\n"
				GroupsUser.email_hook("exhibit", exhibit.group_id, "Exhibit #{exhibit.title} shared in group #{group.name}", body, url_for(:controller => 'home', :action => 'index', :only_path => false))
			end
		end
		render :partial => 'overview_data', :locals => { :exhibit => exhibit, :show_immediately => true }
	end

  def remove_exhibited_object
    user = current_user
    uri = params[:uri]
    exhibit_id = params[:exhibit_id]
    if Exhibit.can_edit(user, exhibit_id)
      obj = ExhibitObject.find_by_uri_and_exhibit_id(uri, exhibit_id)
      obj.destroy if obj
    end

    render :partial => '/results/exhibited_objects', :locals => { :current_user_id => user.id }
  end

  def change_sharing
    exhibit_id = params[:id]
    user = current_user
    exhibit = Exhibit.find(exhibit_id)
    if Exhibit.can_edit(user, exhibit_id)
      sharing_level = params[:sharing]
      exhibit.set_sharing(sharing_level)
      exhibit.save
    end
    render :partial => 'overview_data', :locals => { :exhibit => exhibit, :show_immediately => true }
  end

  def change_page
    exhibit_id = params[:id]
    user = current_user
    if Exhibit.can_edit(user, exhibit_id)
      redirect_to :action => 'show', :id => params['id'], :page => params['page']
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
    user = current_user
    if Exhibit.can_edit(user, exhibit_id)
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
      render :partial => '/exhibits/exhibit_page', :locals => { :exhibit => Exhibit.find(page.exhibit_id), :page_num => page.position, :is_edit_mode => true, :top => nil, :badge_pos => 'none' }
    end
  end

  def edit_row_of_illustrations
    element_id = params[:element_id]
    pos = params[:position].to_i
    element = ExhibitElement.find_by_id(element_id)
    verb = params[:verb]
    user = current_user
    if Exhibit.can_edit(user, get_exhibit_id_from_element(element))
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
    user = current_user
    if Exhibit.can_edit(user, get_exhibit_id_from_element(element))
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
    user = current_user
    if Exhibit.can_edit(user, get_exhibit_id_from_element(element))
      element.exhibit_element_layout_type = type
      element.save
      # if we are just creating an element that takes an illustration, then create the illustration, too.
      if (type == 'pic_text' || type == 'text_pic' || type == 'text_pic_text' || type == 'pic_text_pic' || type == 'pics') && element.exhibit_illustrations.length == 0
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
    user = current_user
    if Exhibit.can_edit(user, get_exhibit_id_from_element(element))
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
      render :partial => '/exhibits/exhibit_page', :locals => { :exhibit => exhibit, :page_num => page_num, :is_edit_mode => true, :top => nil, :badge_pos => 'none' }
    end
  end

  def redraw_exhibit_page  # This is called for a number of different ajax actions to update the view.
    page_id = params[:page_id]
    if page_id == nil
      id = params[:element_id]
      if id != nil  # something probably timed out if this happens
        element = ExhibitElement.find_by_id(id)	# This is ok to fail: for instance, if the element was just deleted.
        page_id = element.exhibit_page_id if element != nil
      end
    end
    if page_id != nil
      page = ExhibitPage.find_by_id(page_id)
      if page == nil
        render :text =>'Error in editing section. Please refresh your browser page.'
      else
        render :partial => '/exhibits/exhibit_page', :locals => { :exhibit => Exhibit.find(page.exhibit_id), :page_num => page.position, :is_edit_mode => true, :top => nil, :badge_pos => 'none' }
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
		#footnotes = JSON.parse(params['footnotes'])

    element = ExhibitElement.find_by_id(element_id)
    user = current_user
    if Exhibit.can_edit(user, get_exhibit_id_from_element(element))
      value = params['value']
      value = clean_up_links(value)
      value = remove_empty_spans(value)
      value = strip_word_tags( value )
      if first_one
        element.element_text = value
      else
        element.element_text2 = value
      end
      element.save
		else
			element = nil	#the user probably wasn't logged in; this will cause an error to be reported below.
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
    user = current_user
    if Exhibit.can_edit(user, get_exhibit_id_from_element(element))
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
      user = current_user
      if Exhibit.can_edit(user, get_exhibit_id_from_element(element))
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
    caption1_bold = params['caption1_bold']
    caption1_italic = params['caption1_italic']
    caption1_underline = params['caption1_underline']
    caption2_bold = params['caption2_bold']
    caption2_italic = params['caption2_italic']
    caption2_underline = params['caption2_underline']
	file = params['uploaded_image']
    text = params['ill_text']
    alt_text = params['alt_text']
    nines_object = params['nines_object']
	nines_obj_id = nines_object.to_i
	test_id = "#{nines_obj_id}"
	if test_id == nines_object
		nines_object = CachedResource.find(nines_obj_id).uri
	end
		#footnotes = JSON.parse(params['footnotes'])

    illustration = ExhibitIllustration.find_by_id(illustration_id)
    if illustration != nil
      element_id = illustration.exhibit_element_id
      element = ExhibitElement.find(element_id)
      user = current_user
      if Exhibit.can_edit(user, get_exhibit_id_from_element(element))
        illustration.illustration_type = type
        illustration.image_url = image_url
				text = clean_up_links(text)
				text = remove_empty_spans(text)
				#text = add_footnotes(text, footnotes)
        illustration.illustration_text = text
        illustration.caption1 = caption1
        illustration.caption2 = caption2
        illustration.link = link
        illustration.alt_text = alt_text
        illustration.nines_object_uri = nines_object
				illustration.set_caption_footnote(caption1_footnote, 'caption1_footnote_id')
				illustration.set_caption_footnote(caption2_footnote, 'caption2_footnote_id')
        illustration.caption1_bold = caption1_bold
        illustration.caption1_italic = caption1_italic
        illustration.caption1_underline = caption1_underline
        illustration.caption2_bold = caption2_bold
        illustration.caption2_italic = caption2_italic
        illustration.caption2_underline = caption2_underline
		if file.present?
		illustration.upload = file
		end
        illustration.save

				if (type == 'NINES Object' && nines_object)
					 ExhibitObject.add(get_exhibit_id_from_element(element), nines_object)
				end

        element_id = illustration.exhibit_element_id
        element = ExhibitElement.find(element_id)
      end
    end
    if illustration == nil
      render :text =>'Error in editing section. Please refresh your browser page.'
	elsif illustration.illustration_type == ExhibitIllustration.get_illustration_type_upload()
		redirect_to :back
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

    user = current_user
    if Exhibit.can_edit(user, exhibit_id)
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
		sel = element_id

    user = current_user
    if Exhibit.can_edit(user, exhibit_id)
      case verb
        when "insert_element"
        new_element = page.insert_element(element.position+1)
        element_id = new_element.id
        when "move_element_up"
        ret = page.move_element_up(element.position)
				sel = ret if ret
        when "move_element_down"
        ret = page.move_element_down(element.position)
				sel = ret if ret
        when "delete_element"
        page.delete_element(element.position)
        element_id = -1

        when "insert_page"
        exhibit.insert_page(page.position+1)
      end
    end

    render :partial => 'exhibit_outline', :locals => { :exhibit => Exhibit.find(exhibit_id), :element_id_selected => sel, :is_editing_border => is_editing_border }
  end

  def modify_outline_add_first_element
    page_id = params[:page_id]
    page = ExhibitPage.find(page_id)
    exhibit_id = page.exhibit_id
    is_editing_border = false

    user = current_user
    if Exhibit.can_edit(user, exhibit_id)
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
    arr = div_id.split('_')
    el_num = arr[arr.length-1].to_i
    element = ExhibitElement.find(el_num)
    page = ExhibitPage.find(element.exhibit_page_id)

    render :partial => '/exhibits/exhibit_page', :locals => { :exhibit => Exhibit.find(page.exhibit_id), :page_num => page.position, :is_edit_mode => true, :top => el_num, :badge_pos => 'none' }
  end

	# POST /builder
	# POST /builder.xml
	def create
		exhibit_url = params[:exhibit_url]
		visible_url = Exhibit.transform_url(exhibit_url)
		exhibit_title = params[:exhibit_title]
		exhibit_thumbnail = params[:exhibit_thumbnail]
		group_id = params[:group_id]
		cluster_id = params[:cluster_id]
		objects = params[:objects].split("\t")
		user = current_user
		if user == nil
			render :text => 'Your session has timed out due to inactivity. Please login again to create an exhibit', :status => :bad_request
		else
			ex = Exhibit.find_by_visible_url(visible_url)
			if ex != nil
				render :text => "There is already an exhibit in #{Setup.site_name()} with the url \"#{exhibit_url}\". Please choose another.", :status => :bad_request
			else
				exhibit = Exhibit.factory(user.id, visible_url, exhibit_title, exhibit_thumbnail, group_id, cluster_id)
				ExhibitObject.set_objects(exhibit.id, objects)
				render :text => "#{exhibit.id}"
			end
		end
	end

	def import_exhibit
		user = current_user
		if user == nil
			render :text => respond_to_file_upload("stopCreateNewExhibitUpload", 'Your session has timed out due to inactivity. Please login again to create an exhibit'), :status => :bad_request
		else
			exhibit_id = params[:exhibit_id]
			file = params[:document]
			if file
				begin
					paragraphs = Exhibit.process_input_file(file)
				rescue Exception => e
					# The import failed.
					exhibit = Exhibit.find(exhibit_id)
					exhibit.destroy if exhibit
					render :text => respond_to_file_upload("stopCreateNewExhibitUpload", e.to_s), :status => :bad_request
					return
				end
				exhibit = Exhibit.find(exhibit_id)	#create({ :title => exhibit_title, :user_id => user.id })
				#exhibit.reset_fonts_to_default()
				#exhibit.bump_last_change()
				#exhibit.delete_page(2)
				exhibit.delete_page(1)
				new_page = ExhibitPage.create(:exhibit_id => exhibit.id)
				new_page.insert_at(1)
				paragraphs.each_with_index {|para, i|
					el = new_page.insert_element(i+1)
					el.element_text = para[:text]
					el.save
					el.change_layout(para[:type])
				}
			end
			render :text => respond_to_file_upload("stopCreateNewExhibitUpload", "OK:/builder/#{exhibit_id}")
		end
	end

  def update_objects_in_exhibits
    exhibit_id = params[:exhibit_id]
    user = current_user
    if Exhibit.can_edit(user, exhibit_id)
      objects = params[:objects].split("\t")
      ExhibitObject.set_objects(exhibit_id, objects)
			Exhibit.find(exhibit_id).bump_last_change()
    end
    render :partial => 'exhibit_palette', :locals => { :exhibit => Exhibit.find(exhibit_id) }

  end

  # Get a list of users that the current user can use to publish 
  # Rules: 
  #   site admins publishing outside of a group can use anyone
  #   site or group admins publishing from a group can use anyone from that group
  def get_alias_users
    
    # Init data
    exhibit_id = params[:exhibit_id]
    exhibit = Exhibit.find(exhibit_id)
    curr_user = current_user
    ret = []
    
    ret.push( {:value  => -1, :text => '- Select a user -'})
   
    # get correct list of users based on role and exhibit group
    # exclude the currently logged in user from the lists
    if exhibit.group.nil?
      if is_admin?
        users = User.all() 
        # On IE, there are lots of characters that cause 
        # the json to be illegal. We'll just replace most weird characters just in case.
        users.each do |user|  
          if user.id != curr_user.id
            ret.push({ :value => user.id, :text => user.fullname.gsub(/[^-'a-zA-Z0-9_. ]/, "*") })
          end
        end
      end  
    else
      members = exhibit.group.get_membership_list(true)
      members.each do | member |  
        if member[:user_id] != curr_user.id
          ret.push({ :value => member[:user_id], :text => member[:name].gsub(/[^-'a-zA-Z0-9_. ]/, "*") })
        end
      end
    end
    
    render :text => ret.to_json()
  end

  # Set an alias for the exhibit author based on the POST params
  #
  def set_exhibit_author_alias  
    exhibit_id = params[:exhibit_id]
    user_id = params[:user_id]
    page_num = params[:page_num].to_i
    #user = current_user
    exhibit = Exhibit.find(exhibit_id)
    
    puts "ALIAS of EXHIBIT #{exhibit.title} is USER_ID: #{user_id}"
    
    if user_id.to_i > 0
      exhibit.alias_id = user_id
      exhibit.save
    elsif user_id.to_i == -1
      exhibit.alias_id = nil
      exhibit.save
    end
    render :partial => '/exhibits/exhibit_page', :locals => { :exhibit => exhibit, :page_num => page_num, :is_edit_mode => true, :top => nil, :badge_pos => 'none' }
  end

	def add_additional_author
		exhibit_id = params[:exhibit_id]
		user_id = params[:user_id]
		page_num = params[:page_num].to_i
		user = current_user
		exhibit = Exhibit.find(exhibit_id)
		if user_id.to_i > 0 && Exhibit.can_edit(user, exhibit_id)
			authors = exhibit.additional_authors == nil ? [] : exhibit.additional_authors.split(',')
			authors.push(user_id)
			exhibit.additional_authors = authors.join(',')
			exhibit.save
		end
		render :partial => '/exhibits/exhibit_page', :locals => { :exhibit => exhibit, :page_num => page_num, :is_edit_mode => true, :top => nil, :badge_pos => 'none' }
	end

	def remove_additional_author
		exhibit_id = params[:exhibit_id]
		user_id = params[:user_id]
		user = current_user
		exhibit = Exhibit.find(exhibit_id)
		if user_id.to_i > 0 && Exhibit.can_edit(user, exhibit_id)
			authors = exhibit.additional_authors == nil ? [] : exhibit.additional_authors.split(',')
			authors.delete(user_id)
			exhibit.additional_authors = authors.join(',')
			exhibit.save
		end
		render :partial => '/exhibits/exhibit_page', :locals => { :exhibit => exhibit, :page_num => 1, :is_edit_mode => true, :top => nil, :badge_pos => 'none' }
	end

  def modify_outline_page
    exhibit_id = params['exhibit_id']
    page_num = params['page_num'].to_i
    verb = params['verb']
    element_id = params['element_id']

    exhibit = Exhibit.find(exhibit_id)

    user = current_user
    if Exhibit.can_edit(user, exhibit_id)
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

	# GET /builder/1
	# GET /builder/1.xml
	def show
		exhibit_id = params[:id]
		user = current_user
		if Exhibit.can_edit(user, exhibit_id)
			@exhibit = Exhibit.find(exhibit_id)
			@page = params['page'] == nil ? 1 : params['page'].to_i
			num_pages = @exhibit.exhibit_pages.length
			@page = num_pages if @page > num_pages
			@exhibit.bump_last_change()
		else
			redirect_to :controller => 'my_collex', :action => 'index'
		end
	end

	# PUT /builder/1
	# PUT /builder/1.xml
	def update

	end

	# DELETE /builder/1
	# DELETE /builder/1.xml
	def destroy
		# for security reasons, make sure that the exhibit belongs to the person who is trying to delete it.
		exhibit_id = params[:id]
		user = current_user
		#exhibit = Exhibit.find(exhibit_id)
		if Exhibit.can_edit(user, exhibit_id)
			Exhibit.destroy(exhibit_id)
		end

		redirect_to :controller => 'my_collex', :action => 'index'
	end
end
