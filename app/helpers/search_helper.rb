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

module SearchHelper
  private
  def get_collected_item(hit)
    return nil if session[:user] == nil || hit == nil
    if @cached_collected_item
      if @cached_collected_item[:user] == session[:user][:username] && @cached_collected_item[:uri] == hit['uri']
        return @cached_collected_item[:item]
      end
    end
    user = User.find_by_username(session[:user][:username])
    item = CollectedItem.get(user, hit['uri'])
    @cached_collected_item = { :user => session[:user][:username], :uri => hit['uri'], :item => item }
    return item
  end

#  # TODO-PER: remove this when upgrading rails.
#  def raw(str)
#	  return str
#  end
  
  public
	def format_tag_for_output(tag)
		# we want this escaped, so the user can't inject anything, and lower case, and we want invisible breaks so that a long tag won't break the spacing

		# any dashes and underscores can be split
		words = tag.split('_')
		arr_outer = []
		words.each {|word|
			words2 = word.split('-')
			arr_inner = []
			words2.each {|word2|
				# now we have an expanse that contains neither dashes nor underscores. Split this arbitrarily if it is too long,
				# then put the entire piece back together, with splits after the dashes and underscores.
				len = word2.length-16
				while len > 0
					word2 = word2.insert(len, '&#x200B;')
					len -= 16
				end
				arr_inner.push(word2)
			}
			arr_outer.push(arr_inner.join('-&#x200B;'))
		}
		tag = arr_outer.join('_&#x200B;')
		tag = h(tag).downcase()
		tag = tag.gsub("&amp;#x200b;", "&#x200b;")	# but don't escape the hidden character we inserted.
		return raw(tag)
	end

  def draw_pagination(curr_page, num_pages, destination_hash)
    html = ""

    # If there's only one page, don't show any pagination
    if num_pages == 1
      return ""
    end
    
    # Show only a maximum of 11 items, with the current item centered if possible.
    # First figure out the start and end points we want to display.
    if num_pages < 11
      first = 1
      last = num_pages
    else
      first = curr_page - 5
      last = curr_page + 5
      if first < 1
        first = 1
        last = first + 10
      end
      if last > num_pages
        last = num_pages
        first = last - 10
      end
    end

	link = "/#{destination_hash[:controller]}/#{destination_hash[:action]}"
	destination_hash.delete(:controller)
	destination_hash.delete(:action)
    
    if first > 1
      destination_hash[:page] = "#{1}"
      html += create_facet_link('first', link, destination_hash)
      html += "&nbsp;&nbsp;"
    end

    if curr_page > 1
      destination_hash[:page] = "#{(curr_page - 1)}"
      html += create_facet_link('<<', link, destination_hash)
      html += "&nbsp;&nbsp;"
    end

    for pg in first..last do
      if pg == curr_page
        html += "<span class='current_serp'>#{pg}</span>"
      else
        destination_hash[:page] = "#{pg}"
        html += create_facet_link("#{pg}", link, destination_hash)
      end
      html += "&nbsp;&nbsp;"
    end 
    
    if last < num_pages
      html += "...&nbsp;&nbsp;" if num_pages > 12
      destination_hash[:page] = "#{num_pages}"
      html += create_facet_link(num_pages, link, destination_hash)
      html += "&nbsp;&nbsp;"
    end
    
    if curr_page < num_pages
      destination_hash[:page] = "#{(curr_page + 1)}"
      html += create_facet_link(">>", link, destination_hash)
      html += "&nbsp;&nbsp;"
    end
    
    if last < num_pages
      destination_hash[:page] = "#{num_pages}"
      html += create_facet_link("last", link, destination_hash)
      html += "&nbsp;&nbsp;"
    end

    return raw(html)
  end

  def draw_ajax_pagination(curr_page, num_pages, action, el)
    html = ""

    # If there's only one page, don't show any pagination
    if num_pages == 1
      return ""
    end

    # Show only a maximum of 11 items, with the current item centered if possible.
    # First figure out the start and end points we want to display.
    if num_pages < 11
      first = 1
      last = num_pages
    else
      first = curr_page - 5
      last = curr_page + 5
      if first < 1
        first = 1
        last = first + 10
      end
      if last > num_pages
        last = num_pages
        first = last - 10
      end
    end
	spacing = raw("&nbsp;&nbsp;")

    if first > 1
      html += link_to_function("first", "ajax_pagination('#{action}', '#{el}', 1)", :class => 'nav_link') + spacing
    end

    if curr_page > 1
      html += link_to_function("<<", "ajax_pagination('#{action}', '#{el}', #{ curr_page - 1 })", :class => 'nav_link') + spacing
    end

    for pg in first..last do
      if pg == curr_page
        html += "<span class='current_serp'>#{pg}</span>"
      else
        html += link_to_function("#{pg}", "ajax_pagination('#{action}', '#{el}', #{ pg })", :class => 'nav_link' )
      end
      html += "&nbsp;&nbsp;"
    end

    if last < num_pages
      html += "..."+spacing if num_pages > 12
      html += link_to_function(num_pages, "ajax_pagination('#{action}', '#{el}', #{ num_pages })", :class => 'nav_link') + spacing
    end

    if curr_page < num_pages
      html += link_to_function( ">>", "ajax_pagination('#{action}', '#{el}', #{ curr_page + 1 })", :class => 'nav_link') + spacing
    end

    if last < num_pages
      html += link_to_function("last", "ajax_pagination('#{action}', '#{el}', #{ num_pages })", :class => 'nav_link') + spacing
    end

    return raw(html)
  end

  def resource_is_in_constraints?(resource)
    constraints = session[:constraints]
    constraints.each {|constraint|
      if constraint[:fieldx] == 'archive' && constraint[:type] == 'FacetConstraint' && constraint[:value] == resource.value
        return true
      end
    }
    return false
  end
  
  def site_is_in_constraints?(site_value)
    constraints = session[:constraints]
	return false if constraints == nil
    constraints.each {|constraint|
      if constraint[:fieldx] == 'archive' && constraint[:type] == 'FacetConstraint' && constraint[:value] == site_value
        return true
      end
    }
    return false
  end
  
  def access_is_in_constraints?(type)
    constraints = session[:constraints]
    constraints.each {|constraint|
      if constraint[:type] == type
        return true
      end
    }
    return false
  end

  def free_culture_is_in_constraints?
    constraints = session[:constraints]
    constraints.each {|constraint|
      if constraint[:type] == 'FreeCultureConstraint'
        return true
      end
    }
    return false
  end

  def full_text_is_in_constraints?
    constraints = session[:constraints]
    constraints.each {|constraint|
      if constraint[:type] == 'FullTextConstraint'
        return true
      end
    }
    return false
  end

  def genre_data_link( genre_data )
    if genre_data[:exists]
      html = "<span class='resource_list_selected'>&rarr; #{h genre_data[:value]} (#{pluralize(genre_data[:count], 'object')})</span>&nbsp;"
      html += create_facet_link("[remove]", "/search/remove_genre", { :value => genre_data[:value]})
      return html
    else
		create_facet_link("#{h genre_data[:value]} (#{pluralize(genre_data[:count], 'object')})", "/search/add_facet", { :fieldx => 'genre', :value => genre_data[:value]})
    end

  end
  
  def site_subtotal(site_count, facet_category)
    count = 0
    if facet_category['children'] != nil
      facet_category['children'].each { |child|
        if child['children'] != nil
          count = count + site_subtotal(site_count, child)
        else
          count = count + site_object_count(site_count, child['handle'])
        end    
      }
    else
      count = site_object_count(site_count, facet_category['handle'])
    end
    return count
  end
    
  def is_constrained_by_child(resource)
    constraints = session[:constraints]
    resource_constraint = ""
    constraints.each {|constraint|
      if constraint[:fieldx] == 'archive' && constraint[:type] == 'FacetConstraint'
        resource_constraint = constraint[:value]
      end
    }
    return false if resource_constraint == ""
    
    resource.children.each {|child|
      return true if child['value'] == resource_constraint
    }
    
    return false
  end
  
#  def mark_as_checked_freeculture()
#    session[:selected_freeculture] ? 'checked="checked"' : ''  
#  end
#  
#  def mark_as_checked_resource( facet )
#    session[:selected_resource_facets].include?(facet) ? 'checked="checked"' : ''
#  end
  
  def gray_if_zero( count )
    count==0 ? 'class="grayed-out-resource"' : ''
  end
    
  def site_object_count(site_count, code)
	  return 0 if site_count[code] == nil
    site_count[code].to_i
  end
  
  def result_is_collected(hit)
    return get_collected_item(hit) != nil
  end
  
  #def add_tag_if_present(hit)
  #  item = get_collected_item(hit)
  #  return "" if item == nil
  #
  #  str = ""
  #  tags = item.tags
  #  if tags != nil
  #    str = "<ul style='list-style-type: none;'><li>Collected On: #{item.updated_at}</li>\n"
  #    tags.each {|t|
  #      str += "<li>x&nbsp;#{h tags.name}</li>\n"
  #    }
  #    str += "<a class='modify_link' href='#'>Add a tag</a>\n"
  #    str += "</ul>\n"
  #  end
  #  return raw(str)
  #end

  def has_annotation(hit)
    item = get_collected_item(hit)
    return false if item == nil
    
    return  item.annotation != nil && item.annotation != ""
  end
  
  def get_annotation(hit)
    item = get_collected_item(hit)
    return "" if item == nil
    return "" if item.annotation == nil
    note = item.annotation
    note = note.gsub("\n", "<br />")
    return note
  end

  #def get_result_date(hit)
  #
  #end
  #
  #def get_result_annotation(hit)
  #
  #end
  #
  #def result_has_annotation(hit)
  #
  #end
  #
  #def get_result_tags(hit)
  #
  #end
  
  def get_saved_searches(username)
    user = User.find_by_username(username)
    return user.searches.find(:all).sort { |a,b| b.id <=> a.id }
  end
  
  def encode_for_uri(str)
    value = str.gsub('%', '%25')
    value = value.gsub('#', '%23')
    value = value.gsub('&', '%26')
    value = value.gsub(/\?/, '%3f')
    value = value.gsub('.', '%2e')
    value = value.gsub('"', '%22')
    value = value.gsub("'", '%27')
    value = value.gsub("<", '%3c')
    value = value.gsub(">", '%3e')
    value = value.gsub("\\", '%5c')
    return value
  end
  
  def create_saved_search_url(user_name, search_name)
    "/search/saved?user=#{user_name}&name=#{encode_for_uri(search_name)}"
  end
  
  def create_saved_search_permalink(s)
    base_url = 'http://' + request.host_with_port()
    permalink_id = "permalink_#{encode_for_uri(h(s))}"
    return raw("<a id='#{permalink_id}' class='nav_link' href='#' onclick='showString(\"#{base_url}#{create_saved_search_url(session[:user][:username], s)}\"); return false;'><img src='/images/link.jpg' title=\"Click here to get a permanent link for this saved search.\" alt=\"\"/></a>")
  end

  def create_saved_search_link(s)
    return raw("<a class='nav_link' href='#{create_saved_search_url(session[:user][:username], s.name)}'>#{h(s.name)}</a>")
    #link_to s.name, {:controller=>"search", :action => 'apply_saved_search', :username => session[:user][:username], :name => s.name }, :class => 'nav_link'
  end

  def create_remove_saved_search_link(s)
    link_to_confirm("[remove]", { :controller => 'search', :action => 'remove_saved_search', :username => session[:user][:username], :id => s.id}, 'Saved Search', 'Are you sure you want to remove this saved search?')
  end
  
  def has_constraints?
	  # don't count the federation constraint
    session[:constraints].each { |constraint|
		return true if !constraint.is_a?(FederationConstraint)
	}
	return false
  end

  def has_federation_constraint?(value)
	  # If no federation constraint has been defined, we return true. Otherwise, we have to match it.
	  found_fed = false
    session[:constraints].each { |constraint|
		return true if constraint.is_a?(FederationConstraint) && constraint.value == value
		found_fed = true if constraint.is_a?(FederationConstraint)
	}
	return !found_fed
  end

	def has_all_federation_constraints?(feds)
		feds.each { |fed|
			return false if !has_federation_constraint?(fed)
		}
		return true
	end
  
  def format_constraint(constraint)

    ret = {}
    value_display = constraint.value
    if constraint.fieldx =="archive"
      if site(constraint.value)
        value_display = site(constraint.value)['name']
      end
    end
    
    ret[:not] = constraint.inverted
    if constraint.is_a?(FreeCultureConstraint)
      ret[:title] ="Free Culture"
      ret[:value] = 'Only resources that are freely available in their full form'
    elsif constraint.is_a?(FullTextConstraint)
      ret[:title] ="Full Text"
      ret[:value] = 'Only resources that contain full text'
    elsif constraint.is_a?(TypeWrightConstraint)
      ret[:title] ="TypeWright"
      ret[:value] = 'Only resources that can be edited'
    elsif constraint.is_a?(ExpressionConstraint)
      ret[:title] ="Search Term"
      ret[:value] = constraint.value
    elsif constraint.is_a?(FacetConstraint) && constraint[:fieldx] == 'genre'
      ret[:title] ="Genre"
      ret[:value] = value_display
    elsif constraint.is_a?(FacetConstraint) && constraint[:fieldx] == 'title'
      ret[:title] ="Title"
      ret[:value] = value_display
    elsif constraint.is_a?(FacetConstraint) && constraint[:fieldx] == 'year'
      ret[:title] ="Year"
      ret[:value] = value_display
    elsif constraint.is_a?(FacetConstraint) && constraint[:fieldx] == 'author'
      ret[:title] ="Author"
      ret[:value] = value_display
    elsif constraint.is_a?(FacetConstraint) && constraint[:fieldx] == 'editor'
      ret[:title] ="Editor"
      ret[:value] = value_display
    elsif constraint.is_a?(FacetConstraint) && constraint[:fieldx] == 'publisher'
      ret[:title] ="Publisher"
      ret[:value] = value_display
#    elsif constraint.is_a?(FacetConstraint) && constraint[:fieldx] == 'federation'
#      ret[:title] = "Federation"
#      ret[:value] = value_display
    elsif constraint.is_a?(FacetConstraint) && constraint[:fieldx] == 'language'
      ret[:title] = "Language"
      ret[:value] = value_display.split(/\|\|/)[0]
    elsif constraint.is_a?(FacetConstraint) && constraint[:fieldx] == 'r_art'
      ret[:title] ="Artist"
      ret[:value] = value_display
    elsif constraint.is_a?(FacetConstraint) && constraint[:fieldx] == 'r_own'
      ret[:title] ="Owner"
      ret[:value] = value_display
    elsif constraint.is_a?(FacetConstraint) && constraint[:fieldx] == 'fuz_q'
      ret[:title] ="Keyword Fuzziness"
      ret[:value] = value_display
    elsif constraint.is_a?(FacetConstraint) && constraint[:fieldx] == 'fuz_t'
      ret[:title] ="Title Fuzziness"
      ret[:value] = value_display
    elsif constraint.is_a?(FacetConstraint) && constraint[:fieldx] == 'doc_type'
      ret[:title] ="Format"
      ret[:value] = value_display
    elsif constraint.is_a?(FacetConstraint) && constraint[:fieldx] == 'discipline'
      ret[:title] ="Discipline"
      ret[:value] = value_display
    elsif constraint.is_a?(FacetConstraint) && constraint[:fieldx].match(/role_/) && Search.role_field_names[constraint[:fieldx]]
      ret[:title] = Search.role_field_names[constraint[:fieldx]][:display]
      ret[:value] = value_display
    elsif constraint.is_a?(FacetConstraint)
      ret[:title] ="Resource"
      ret[:value] = value_display
    else
      return nil
    end
    return ret
  end
  
  def forum_result_row_item_format(label, item)
    return "<p class='FP_attachment_details'>#{label}:<br />#{item}</p>"
  end

  def forum_result_row_item(type, hit, key, label)
    if !hit[key]
      return ""
    end
    
    if type == :separate_lines
      # multiple items on separate lines
      str = ""
      hit[key].each do |item|
        str += forum_result_row_item_format(label, h(item))
      return str
      end

    elsif type == :single_item
      # single item
      return forum_result_row_item_format(label, h(hit[key]))

    elsif type == :multiple_item
      # multiple item, one line
      return forum_result_row_item_format(label, h(hit[key].join('; ')))
    end
  end

	def result_row_collected(rows, is_collected, item)
		return if !is_collected
		rows.push({:hidden => false, :label => "Collected&nbsp;on:", :value => item.updated_at.strftime("%b %d, %Y")})
	end

	def result_row_tags_no_links(rows, label, tags)
		return if tags.length == 0
		
		# tags is an array returned by the call Tag.get_tags_for_uri.
		# each item in the array is also and array of size 2. 
		# first element sis tag name, second is tag ownership flag
		tag_names = ""
		tags.each do | tag |
		  tag_names += "; " if tag_names.length > 0
		  tag_names += tag[0]  
		end
		rows.push({:hidden => false, :label => label, :value => tag_names})  
	end

	def result_row_tags_links(rows, index, row_id, hit, label, tags, item, signed_in, is_collected)
		tag_str = ""
		user = session[:user] ? User.find_by_username(session[:user][:username]) : nil

		tags.each { |tag|
			tag_str += " | " if tag != tags[0]
			tag_str += link_to format_tag_for_output(tag[0]), {:controller => '/tag', :action => 'results', :tag => tag[0], :view => 'tag'}, {:class => 'tag_link my_tag', :title => "view all objects tagged \"#{tag[0]}\""}
			if user && user.id == tag[1][:user]
				tag_str += ' ' + link_to_function("X", "doRemoveTag('#{hit['uri']}', '#{row_id}', #{tag[1][:tag]});", :class => 'modify_link my_tag remove_tag', :title => "delete tag \"#{tag[0]}\"")
			end #if this tag was created by the current user
		} #the tag loop

		if !signed_in
			tag_str += "<span class='tags_instructions'>#{" [#{sign_in_link({:class => 'nav_link'})} to add tags]"}</span>"
		else
			tag_str += ' ' + link_to_function(raw("[add&nbsp;tag]"), "doAddTag('/tag/tag_name_autocomplete', 'add_tag_#{index}', '#{hit['uri']}', #{index}, '#{row_id}', event);", :id => "add_tag_#{index}", :class => 'modify_link')
		end #if the user is logged in.
		rows.push({:hidden => false, :label => label, :value => tag_str})
	end

	def result_row_site(rows, label, hit, key)
		return if !hit[key]
		archive = hit[key].kind_of?(Array) ? hit[key][0] : hit[key]
		this_site = site(archive)
		if this_site
			str = "<a class='nines_link' target='_blank' href='#{this_site['site_url']}'>#{this_site['name']}</a>"
		else
			str = archive
		end
		rows.push({:hidden => false, :label => label, :value => str})
	end

	def result_row_exhibits(rows, hit, curr_user)
		exhibits = ExhibitObject.find_all_by_uri(hit['uri'])
		is_first = true
		user_name = curr_user ? curr_user.fullname : ''
		for exhibit in exhibits
			# We only want to display the exhibit if it can be viewed, so only if it is owned by the current user, or is public
			# We only want to have the edit link if it is owned by the current user.
			real_exhibit = Exhibit.find(exhibit.exhibit.id)
			owner = User.find(real_exhibit.user_id)
			if user_name == owner.username || real_exhibit.published?
				label = is_first ? "Exhibits:" : ""
				is_first = false
				value = "#{real_exhibit.title} <a class='nav_link' href='/exhibits/#{real_exhibit.visible_url != nil && real_exhibit.visible_url.length > 0 ? real_exhibit.visible_url : real_exhibit.id}' >[view]</a>"
				if Exhibit.can_edit(curr_user, real_exhibit.id)
					value += link_to("[edit]", { :controller => 'builder', :action => 'show', :id => real_exhibit.id }, :class => 'nav_link' )
				end
				rows.push({:hidden => true, :id => "in_exhibit_#{exhibit.exhibit.id}_#{hit['uri']}", :label => label, :value => value})
			end
		end # each exhibit
	end
	
	def should_show_more_link(no_links, rows)
		# show more if we aren't in a special mode and if there are more than 1 hidden items
		return false if no_links
		count = 0
		rows.each {|row| count += 1 if row[:hidden] }
		return count > 1
	end
	
	def format_result_rows(rows, hide_some)
		html = ""
		rows.each { |row|
			if row[:one_col]
				html += "<tr #{ 'class="hidden"' if row[:hidden] && hide_some}><td valign='top' colspan='2'>#{row[:value]}</td></tr>\n"
			else
				html += "<tr #{ 'class="hidden"' if row[:hidden] && hide_some}><td valign='top' class='search_result_data_label'>#{row[:label]}</td><td valign='top' class='search_result_data_value'>#{row[:value]}</td></tr>\n"
			end
		}
		return raw(html)
	end

	def result_row_title(title, url, index)
		if title.length < 200
			return content_tag(:a, title, { class: 'nines_link', title: ' ', target: '_blank', href: url })
		else
			title1 = title[0..199]
			title2 = title[200..-1]
			id = "title_more_#{index}"
			initial_title = title1 + content_tag(:span, title2, { id: id, class: 'hidden' })
			return content_tag(:a, raw(initial_title), { class: 'nines_link', title: ' ', target: '_blank', href: url }) +
				content_tag(:a, '...[show full title]', { href: '#', onclick: 'return false;', class: 'nav_link more_link', 'data-div' => id, 'data-less' => '[show less]' })
		end
	end

  def result_row_item(rows, type, hit, key, label, is_hidden)
    return if !hit[key]
    
    if type == :separate_lines
      # multiple items on separate lines
      hit[key].each_with_index do |item, i|
		  rows.push({:hidden => is_hidden, :label => (i < 1) ? label+':' : '', :value => h(item)})
      end

    elsif type == :single_item
      # single item
	  rows.push({:hidden => is_hidden, :label => label+':', :value => h(hit[key])})

    elsif type == :multiple_item
      # multiple item, one line
	  rows.push({:hidden => is_hidden, :label => label+':', :value => h(hit[key].join('; '))})

	elsif type == :alternative
		hit[key].each do |alt|
			rows.push({:hidden => is_hidden, :one_col => true, :value => h(alt)})
		end
    end
  end
  
  ##############################
  # Helpers for the facet tree that shows resources
  # These are called either in edit mode or normal mode
  # For the administrator page or the search page.
  def site_selector(site, indent, is_edit_mode, is_category, parent_id, start_hidden, is_found, is_open, site_count )
    display_name = h(site['name'])
    id = site['id']
    value = site['handle']
    
    # This is one line in the resources.
    # If edit mode: don't show # objects, show value instead.
    # if category, put in arrow for expand/collapse
    html = "<tr id='resource_#{id}' class='#{'resource_node ' if is_category}#{parent_id}#{ ' hidden' if start_hidden }#{ ' limit_to_selected' if site_is_in_constraints?(value) }'><td class='limit_to_lvl#{indent}'>\n"
    if is_category
      html += "<a id='site_opened_#{id}' #{'class=hidden' if !is_open} href='#' onclick='new ResourceTree(\"#{id}\", \"open\"); return false;'><img src='/images/arrow.gif' /></a>"
      html += "<a id='site_closed_#{id}' #{'class=hidden' if is_open} href='#' onclick='new ResourceTree(\"#{id}\",\"close\"); return false;'><img src='/images/arrow_dn.gif' /></a>\n"
    end
    
    if is_edit_mode
       if is_found
        html += display_name
      else
        html += "<b>Not found: " + display_name + "</b>"
      end
      html += " [#{value}]" if !is_category
      html += "</td><td class='num_objects'>#{'Yes' if site.carousel_include == 1}</td><td class='edit_delete_col'>"
      sanitized_value = value.gsub("'") { |apos| "&apos;" }
      if is_found
        html += "<a href='#' class='modify_link' onclick='new EditFacetDialog(\"edit_site_list\", \"/admin/facet_tree/edit_facet\", \"#{sanitized_value}\", \"/admin/facet_tree/get_categories_and_details\"); return false;'>[edit]</a>"
        html += "<a href='#' class='modify_link' onclick='new DeleteFacetDialog(\"edit_site_list\", \"/admin/facet_tree/delete_facet\", \"#{sanitized_value}\", #{is_category}); return false;'>[delete]</a>"
      else
        html += "<a class='modify_link' href='#' onclick='new RemoveSiteDlg(\"edit_site_list\", \"/admin/facet_tree/remove_site\", \"#{sanitized_value}\"); return false;'>[remove]</a>"
      end
    else # not edit mode
      total = site_subtotal(site_count, site)
      if is_category
        html += "<a href='#' onclick='new ResourceTree(\"#{id}\",\"toggle\"); return false;' class='nav_link  limit_to_category' >" + display_name + "</a></td><td class='num_objects'>#{number_with_delimiter(total)}"
      else
        if site_is_in_constraints?(value)
          html += display_name + raw("&nbsp;&nbsp;") + create_facet_link("[X]", '/search/constrain_resource', { :resource => value, :remove => 'true' }) + raw("</td><td class='num_objects'>#{number_with_delimiter(total)}")
        else
          link = create_facet_link(display_name, '/search/constrain_resource', { :resource => value })
          html += "#{link}</td><td class='num_objects'>#{number_with_delimiter(total)}"
        end
      end
    end
    html += "</td></tr>\n"
    return raw(html)
  end

	def federation_selector(federation, num_objects)
		return "" if session.blank? || session[:federations].blank? || session[:federations][federation].blank?
		
		html = "<tr><td>"
		selection = has_federation_constraint?(federation) ? "checked='checked'" : ''
		thumb = session[:federations][federation]['thumbnail']
		html += "<input type='checkbox' name='#{federation}' onchange='changeFederation(this); return false;' #{selection} /><img src='#{thumb}' alt='#{federation}' />"
		html += "</td><td class='num_objects'>#{number_with_delimiter(num_objects)}</td></tr>"
		return raw(html)
  end

  
	def create_facet_link(label, link, params)
		# add the dynamic adding of the search phrase to the params first. We have to thwart the json function because we don't want it quoted.
		params[:phrs] = "$(phrase)"
		json = params.to_json()
		json = json.gsub("\"$(phrase)\"", "$('search_phrase') ? $('search_phrase').getRealValue() : null")
		return link_to_function(label, "serverAction({action: { actions: '#{link}', params: #{json}}, progress: { waitMessage: 'Searching...' }})", { :class => 'nav_link' })
	end
	
  def genre_selector( genre_data )
    if genre_data[:exists]
      html = "<tr class='limit_to_selected'><td>#{h genre_data[:value]}&nbsp;&nbsp;" + create_facet_link('[X]', '/search/remove_genre', {:value => genre_data[:value]})
    else
      html = "<tr><td class='limit_to_lvl1'>" + create_facet_link("#{h genre_data[:value]}", "/search/add_facet", { :fieldx => 'genre', :value => genre_data[:value]})
    end
    html += "</td><td class='num_objects'>#{number_with_delimiter(genre_data[:count])}</td></tr>"
    return raw(html)
  end

  def create_genre_table( genre_data )
    html = raw('<table class="limit_to">')
    html += raw('<tr><th>Genre</th><th class="num_objects"># of Objects</th></tr>')
    for genre in genre_data
      html += genre_selector( genre )
    end
    html += raw('</table>')
    return raw(html)
  end

  def access_selector(count, in_constraints, label, action)
    if in_constraints
      html = "<tr class='limit_to_selected'><td>#{label}&nbsp;&nbsp;" + create_facet_link("[X]", action, { :remove => 'true' })
    else
      html = "<tr><td class='limit_to_lvl1'>" + create_facet_link(label, action, { })
    end
    html += "</td><td class='num_objects'>#{number_with_delimiter(count)}</td></tr>"
    return raw(html)
  end

  def create_access_table( freeculture_count, fulltext_count, typewright_count )
    html = raw('<table class="limit_to">')
    html += raw('<tr><th>Access</th><th class="num_objects"># of Objects</th></tr>')
    html += raw(access_selector(freeculture_count, access_is_in_constraints?('FreeCultureConstraint'), "Free Culture Only", '/search/constrain_freeculture'))
    html += raw(access_selector(fulltext_count, access_is_in_constraints?('FullTextConstraint'), "Full Text Only", '/search/constrain_fulltext'))
    if COLLEX_PLUGINS['typewright']
      html += raw(access_selector(typewright_count, access_is_in_constraints?('TypeWrightConstraint'), "TypeWright Enabled Only", '/search/constrain_typewright'))
    end
    html += raw('</table>')
    return raw(html)
  end


  def format_selector( format_data )
    if format_data[:exists]
      html = "<tr class='limit_to_selected'><td>#{h format_data[:value]}&nbsp;&nbsp;" + create_facet_link('[X]', '/search/remove_format', {:value => format_data[:value]})
    else
      html = "<tr><td class='limit_to_lvl1'>" + create_facet_link("#{h format_data[:value]}", "/search/add_facet", { :fieldx => 'doc_type', :value => format_data[:value]})
    end
    html += "</td><td class='num_objects'>#{number_with_delimiter(format_data[:count])}</td></tr>"
    return raw(html)
  end

  def create_format_table( format_data )
    html = raw('<table class="limit_to">')
    html += raw('<tr><th>Format</th><th class="num_objects"># of Objects</th></tr>')
    for format in format_data
      html += format_selector( format )
    end
    html += raw('</table>')
    return raw(html)
  end

  def discipline_selector( discipline_data )
    if discipline_data[:exists]
      html = "<tr class='limit_to_selected'><td>#{h discipline_data[:value]}&nbsp;&nbsp;" + create_facet_link('[X]', '/search/remove_discipline', {:value => discipline_data[:value]})
    else
      html = "<tr><td class='limit_to_lvl1'>" + create_facet_link("#{h discipline_data[:value]}", "/search/add_facet", { :fieldx => 'discipline', :value => discipline_data[:value]})
    end
    html += "</td><td class='num_objects'>#{number_with_delimiter(discipline_data[:count])}</td></tr>"
    return raw(html)
  end

  def create_discipline_table( discipline_data )
    html = raw('<table class="limit_to">')
    html += raw('<tr><th>Discipline</th><th class="num_objects"># of Objects</th></tr>')
    for discipline in discipline_data
      html += discipline_selector( discipline )
    end
    html += raw('</table>')
    return raw(html)
  end

#  def free_culture_selector(count)
#    if free_culture_is_in_constraints?
#      html = "<tr class='limit_to_selected'><td>Free Culture Only&nbsp;&nbsp;" + create_facet_link("[X]", '/search/constrain_freeculture', { :remove => 'true' })
#    else
#      html = "<tr><td class='limit_to_lvl1'>" + create_facet_link("Free Culture Only", '/search/constrain_freeculture', { })
#    end
#    html += "</td><td class='num_objects'>#{number_with_delimiter(count)}</td></tr>"
#    return raw(html)
#  end
#
#  def full_text_selector(count)
#    if full_text_is_in_constraints?
#      html = "<tr class='limit_to_selected'><td>Full Text Only&nbsp;&nbsp;" + create_facet_link("[X]", '/search/constrain_fulltext', { :remove => 'true' })
#    else
#      html = "<tr><td class='limit_to_lvl1'>" + create_facet_link("Full Text Only", '/search/constrain_fulltext', { })
#    end
#    html += "</td><td class='num_objects'>#{number_with_delimiter(count)}</td></tr>"
#    return raw(html)
#  end

	def format_name_facet(name, typ)
		name[0] = name[0].gsub("\"", "")
		return create_facet_link("#{name[0]} (#{name[1]})", '/collex/add_constraint', { :search_type => typ,  :search_not => 'AND', :search => { :phrase => name[0]}, :from_name_facet => 'true' })
	end

	def format_no_name_message(index, total)
		if index == 0 && total == 0
			return raw("<span class='no_names_msg'>No names were contributed for this category.</span>")
		end
		return ""
	end

	# TODO-PER: These are generic routines for creating facet tree rows. We can probably refactor a lot of the stuff above to use them.
	# TODO-PER: The biggest difference is that this sends an ajax call, and the search page does a POST.
	def facet_tree_node_row(id, parent_id, indent_level, start_shown, label, num_objects, start_open)
		html = "<tr id='resource_#{id}' class='resource_node#{" child_of_#{parent_id}" if parent_id != 0}#{' hidden' if !start_shown}'><td class='limit_to_lvl#{indent_level}'>"
		html += "<a id='site_opened_#{id}' #{'class="hidden" ' if start_open}href='#' onclick='new ResourceTree(\"#{id}\", \"open\"); return false;'><img src='/images/arrow.gif' /></a>"
		html += "<a id='site_closed_#{id}' #{'class="hidden" ' if !start_open}href='#' onclick='new ResourceTree(\"#{id}\", \"close\"); return false;'><img src='/images/arrow_dn.gif' /></a>"
		html += "<a href='#' onclick='new ResourceTree(\"#{id}\", \"toggle\"); return false;' class='nav_link  limit_to_category' >#{h(label)}</a></td><td class='num_objects'>#{num_objects}</td></tr>\n"
		return raw(html)
	end

	def facet_tree_selection_row(id, parent_id, indent_level, start_shown, label, num_objects, url, update_div, selected)
		html = "<tr id='resource_#{id}' class='child_of_#{parent_id}#{' hidden' if !start_shown}#{' limit_to_selected' if selected}'><td class='limit_to_lvl#{indent_level}'>"
		# If you want to post, use postLink(this.href) to POST instead of doing an ajax update.
		if selected
			html += "#{h(label)}&nbsp;<a href='#{url}' class='nav_link' onclick=\"serverAction({action: { actions: this.href, els: '#{update_div}'}, progress: { waitMessage: 'Removing Facet...' }}); return false;\">[X]</a>"
		else
			html += "<a href='#{url}' class='nav_link' onclick=\"serverAction({action: { actions: this.href, els: '#{update_div}'}, progress: { waitMessage: 'Adding Facet...' }}); return false;\">#{h(label)}</a>"
		end
		html += "</td><td class='num_objects'>#{num_objects}</td></tr>\n"
		return raw(html)
	end

	def count_children(arr)
		total = 0
		if arr.kind_of?(Array)
			arr.each{|ch|
				if ch.kind_of?(Array)
					total += count_children(ch)
				else
					total += ch[:count]
				end
			}
		else
			total = arr[:count]
		end
		return total
	end

	def create_facet_tree(tree, id_base, url_base, update_div)
		html = ''
		parent_open = {}
		tree.each{|node|
			label = node[:label]
			children = node[:children]
			total = 0
			children.each{|child_label, child_arr|
				total += count_children(child_arr)
			}

			start_open = id_base == 'univ' ? true : false
			if session[:resource_toggle]
				start_open = true if session[:resource_toggle]["#{id_base}-1"] == 'open'
				start_open = false if session[:resource_toggle]["#{id_base}-1"] == 'close'
			end
			parent_open["#{id_base}-1"] = start_open
			html += facet_tree_node_row("#{id_base}-1", 0, 1, true, label, total, start_open)
			i = -2
			children.each{|child_label, child_arr|
				if child_arr.kind_of?(Array)
#					start_open = id_base == 'univ' ? true : false
					start_open = false
					if session[:resource_toggle]
						start_open = true if session[:resource_toggle]["#{id_base}#{i}"] == 'open'
						start_open = false if session[:resource_toggle]["#{id_base}#{i}"] == 'close'
					end
					parent_open["#{id_base}#{i}"] = parent_open["#{id_base}-1"] ? start_open : false
					html += facet_tree_node_row("#{id_base}#{i}", "#{id_base}-1", 2, parent_open["#{id_base}-1"], child_label, count_children(child_arr), start_open)
					child_arr.each{|item|
						#start_shown = start_open	# we start shown if the parent starts open
						html += facet_tree_selection_row("#{id_base}#{item[:id]}", "#{id_base}#{i}", 3, parent_open["#{id_base}#{i}"], item[:name], item[:count], "#{url_base}#{item[:id]}", update_div, item[:selected])
					}
					i -= 1
				else
					item = child_arr
					html += facet_tree_selection_row("#{id_base}#{item[:id]}", "#{id_base}#{-1}", 2, parent_open["#{id_base}-1"], item[:name], item[:count], "#{url_base}#{item[:id]}", update_div, item[:selected])
				end
			}
		}
		return raw(html)
	end
	end
