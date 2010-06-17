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
  
  public
	def format_tag_for_output(tag)
		# we want this escaped, so the user can't inject anything, and lower case, and we want invisible breaks so that a long tag won't break the spacing
		tag = h(tag).downcase()
		len = tag.length-10
		while len > 0
			tag = tag.insert(len, '&#x200B;')
			len -= 10
		end
		return tag
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
    
    if first > 1
      destination_hash[:page] = 1
      html += link_to("first", destination_hash, :class => 'nav_link') + "&nbsp;&nbsp;"
    end

    if curr_page > 1
      destination_hash[:page] = (curr_page - 1)
      html += link_to("<<", destination_hash, :class => 'nav_link') + "&nbsp;&nbsp;"
    end

    for pg in first..last do
      if pg == curr_page
        html += "<span class='current_serp'>#{pg}</span>"
      else
        destination_hash[:page] = pg
        html += link_to("#{pg}", destination_hash, :class => 'nav_link' )
      end
      html += "&nbsp;&nbsp;"
    end 
    
    if last < num_pages
      html += "...&nbsp;&nbsp;" if num_pages > 12
      destination_hash[:page] = num_pages
      html += link_to(num_pages, destination_hash, :class => 'nav_link') + "&nbsp;&nbsp;"
    end
    
    if curr_page < num_pages
      destination_hash[:page] = (curr_page + 1)
      html += link_to( ">>", destination_hash, :class => 'nav_link') + "&nbsp;&nbsp;"
    end
    
    if last < num_pages
      destination_hash[:page] = num_pages
      html += link_to("last", destination_hash, :class => 'nav_link') + "&nbsp;&nbsp;"
    end

    return html
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

    if first > 1
      html += link_to_function("first", "ajax_pagination('#{action}', '#{el}', 1)", :class => 'nav_link') + "&nbsp;&nbsp;"
    end

    if curr_page > 1
      html += link_to_function("<<", "ajax_pagination('#{action}', '#{el}', #{ curr_page - 1 })", :class => 'nav_link') + "&nbsp;&nbsp;"
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
      html += "...&nbsp;&nbsp;" if num_pages > 12
      html += link_to_function(num_pages, "ajax_pagination('#{action}', '#{el}', #{ num_pages })", :class => 'nav_link') + "&nbsp;&nbsp;"
    end

    if curr_page < num_pages
      html += link_to_function( ">>", "ajax_pagination('#{action}', '#{el}', #{ curr_page + 1 })", :class => 'nav_link') + "&nbsp;&nbsp;"
    end

    if last < num_pages
      html += link_to_function("last", "ajax_pagination('#{action}', '#{el}', #{ num_pages })", :class => 'nav_link') + "&nbsp;&nbsp;"
    end

    return html
  end

  def resource_is_in_constraints?(resource)
    constraints = session[:constraints]
    constraints.each {|constraint|
      if constraint[:field] == 'archive' && constraint[:type] == 'FacetConstraint' && constraint[:value] == resource.value
        return true
      end
    }
    return false
  end
  
  def site_is_in_constraints?(site_value)
    constraints = session[:constraints]
    constraints.each {|constraint|
      if constraint[:field] == 'archive' && constraint[:type] == 'FacetConstraint' && constraint[:value] == site_value
        return true
      end
    }
    return false
  end
  
#  def resource_data_link( resource )
#    #     <form id="add-constraint" method="post" action="/search/constrain_resources">
#    object_count = site_object_count(resource.value)
#    if object_count != 0
#      display_str = "#{h(resource.display_name)} (#{pluralize( object_count, 'object' )})"
#      if resource_is_in_constraints?(resource)
#        html = "<li><span class='resource_list_selected'>&rarr; #{display_str}</span>&nbsp;"
#        html += link_to "[remove]", { :controller => 'search', :action => "constrain_resources", :resource => resource.value, :remove => true }, { :method => :post, :class => 'nav_link' }
#        html += "</li>"
#        return html
#      else
#        link = link_to display_str, {:controller=>"search", :action => 'constrain_resources', :resource => resource.value }, { :method => :post, :class => 'nav_link' }
#        return "<li>#{link}</li>"
#      end
#    else
#      return ""
#    end
  
#    if resource_data[:exists]
#      html = "&rarr; #{h genre_data[:value]} (#{number_with_delimiter(genre_data[:count])})&nbsp;"
#      html += link_to "[remove]", { :controller => 'search', :action => "remove_genre", :value => genre_data[:value] }, { :method => :post } 
#      return html
#    else
#      link_to "#{h genre_data[:value]} (#{number_with_delimiter(genre_data[:count])})", {:controller=>"search", :action => 'add_facet', :field => 'genre', :value => genre_data[:value]}, { :method => :post } 
#    end

#  end
  
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

#  def federation_is_in_constraints?(value)
#    constraints = session[:constraints]
#    constraints.each {|constraint|
#      if constraint[:type] == 'FacetConstraint' && constraint[:field] == 'federation' && constraint[:value] == value
#        return true
#      end
#    }
#    return false
#  end

#  def free_culture_link(count)
#    display_str = "Free Culture Only (#{pluralize(count, 'object')})"
#    if free_culture_is_in_constraints?
#      html = "<li><span class='resource_list_selected'>&rarr; #{display_str}</span>&nbsp;"
#      html += link_to "[remove]", { :controller => 'search', :action => "constrain_freeculture", :remove => true }, { :method => :post, :class => 'nav_link' }
#      html += "</li>"
#      return html
#    else
#      link = link_to display_str, {:controller=>"search", :action => 'constrain_freeculture' }, { :method => :post, :class => 'nav_link' }
#      return "<li>#{link}</li>"
#    end
#  end
#
  def genre_data_link( genre_data )
    if genre_data[:exists]
      html = "<span class='resource_list_selected'>&rarr; #{h genre_data[:value]} (#{pluralize(genre_data[:count], 'object')})</span>&nbsp;"
      html += link_to "[remove]", { :controller => 'search', :action => "remove_genre", :value => genre_data[:value] }, { :method => :post, :class => 'nav_link' } 
      return html
    else
      link_to "#{h genre_data[:value]} (#{pluralize(genre_data[:count], 'object')})", {:controller=>"search", :action => 'add_facet', :field => 'genre', :value => genre_data[:value]}, { :method => :post, :class => 'nav_link' } 
    end

  end
  
  def site_subtotal(site_count, facet_category)
    count = 0
    if facet_category['type'] == nil
      facet_category.sorted_children.each { |child| 
        if child.children.size > 0 
          count = count + site_subtotal(site_count, child)
        else
          count = count + site_object_count(site_count, child.value)
        end    
      }
    else
      count = site_object_count(site_count, facet_category.value)
    end
    return count
  end
    
  def is_constrained_by_child(resource)
    constraints = session[:constraints]
    resource_constraint = ""
    constraints.each {|constraint|
      if constraint[:field] == 'archive' && constraint[:type] == 'FacetConstraint'
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
  
#  def site_category_heading( category_name, category_id, initial_state = :closed )
#    display_none = 'style="display:none"'
#    label = "<span id=\"cat_#{category_id}_closed\" #{initial_state == :open ? display_none : ''} class=\"site-category-toggle\">"
#    label << link_to_function('&#x25BA; ' + category_name,"toggleCategory('#{category_id}')", { :class => 'nav_link'})
#    label << "</span>"
#    label << "<span id=\"cat_#{category_id}_opened\" #{initial_state == :closed ? display_none : ''} class=\"site-category-toggle\">"
#    label << link_to_function('&#x25BC; ' + category_name, "toggleCategory('#{category_id}')", { :class => 'nav_link' })
#    label << "</span>"
#  '<tr><td><img src="images/arrow_dn.gif" /> Collections</td><td class="num_objects">1,131</td></tr>'
#  end
  
  def result_is_collected(hit)
    return get_collected_item(hit) != nil
  end
  
  def add_tag_if_present(hit)
    item = get_collected_item(hit)
    return "" if item == nil

    str = ""
    tags = item.tags
    if tags != nil
      str = "<ul style='list-style-type: none;'><li>Collected On: #{item.updated_at}</li>\n"
      tags.each {|t|
        str += "<li>x&nbsp;#{tags.name}</li>\n"
      }
      str += "<a class='modify_link' href='#'>Add a tag</a>\n"
      str += "</ul>\n"
    end
    return str
  end

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

  def get_result_date(hit)
    
  end
  
  def get_result_annotation(hit)
    
  end
  
  def result_has_annotation(hit)
    
  end
  
  def get_result_tags(hit)
    
  end
  
  def get_saved_searches
    user = User.find_by_username(session[:user][:username])
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
    return "<a id='#{permalink_id}' class='nav_link' href='#' onclick='showString(\"#{base_url}#{create_saved_search_url(session[:user][:username], s)}\"); return false;'><img src='/images/link.jpg' title=\"Click here to get a permanent link for this saved search.\" alt=\"\"/></a>"
  end

  def create_saved_search_link(s)
    return "<a class='nav_link' href='#{create_saved_search_url(session[:user][:username], s.name)}'>#{h(s.name)}</a>"
    #link_to s.name, {:controller=>"search", :action => 'apply_saved_search', :username => session[:user][:username], :name => s.name }, :class => 'nav_link'
  end

  def create_remove_saved_search_link(s)
    link_to_confirm("[remove]", { :action => 'remove_saved_search', :username => session[:user][:username], :id => s.id}, 'Saved Search', 'Are you sure you want to remove this saved search?')
  end
  
  def is_in_tag_array(arr, str)
    for item in arr
      if str == item['name']
        return true
      end
    end
    return false
  end
  
  def has_constraints?
	  # don't count the federation constraint
    session[:constraints].each { |constraint|
		return true if !constraint.is_a?(FederationConstraint)
	}
	return false
  end

  def has_federation_constraint?(value)
	  # we have a federation constraint as long as a different federation constraint hasn't been defined.
	  # That is, if no federation constraint has been defined, we return true. If this one specifically has been defined, we return true.
    session[:constraints].each { |constraint|
		return false if constraint.is_a?(FederationConstraint) && constraint.value != value
	}
	return true
  end
  
  def format_constraint(constraint)
    ret = {}
    value_display = constraint.value
    if constraint.field=="archive"
      if site(constraint.value)
        value_display = site(constraint.value)['description']
      end
    end
    
    ret[:not] = constraint.inverted
    if constraint.is_a?(FreeCultureConstraint)
      ret[:title] ="Free Culture"
      ret[:value] = 'Only resources that are freely available in their full form'
    elsif constraint.is_a?(FullTextConstraint)
      ret[:title] ="Full Text"
      ret[:value] = 'Only resources that contain full text'
    elsif constraint.is_a?(ExpressionConstraint)
      ret[:title] ="Search Term"
      ret[:value] = constraint.value
    elsif constraint.is_a?(FacetConstraint) && constraint[:field] == 'genre'
      ret[:title] ="Genre"
      ret[:value] = value_display
    elsif constraint.is_a?(FacetConstraint) && constraint[:field] == 'title'
      ret[:title] ="Title"
      ret[:value] = value_display
    elsif constraint.is_a?(FacetConstraint) && constraint[:field] == 'year'
      ret[:title] ="Year"
      ret[:value] = value_display
    elsif constraint.is_a?(FacetConstraint) && constraint[:field] == 'author'
      ret[:title] ="Author"
      ret[:value] = value_display
    elsif constraint.is_a?(FacetConstraint) && constraint[:field] == 'editor'
      ret[:title] ="Editor"
      ret[:value] = value_display
    elsif constraint.is_a?(FacetConstraint) && constraint[:field] == 'publisher'
      ret[:title] ="Publisher"
      ret[:value] = value_display
#    elsif constraint.is_a?(FacetConstraint) && constraint[:field] == 'federation'
#      ret[:title] = "Federation"
#      ret[:value] = value_display
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
      hit[key].each_with_index do |item, i|
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
  
  def result_row_item(type, hit, key, label, is_hidden)
    if !hit[key]
      return ""
    end
    
    cls = is_hidden ? "class='hidden'" : ""
    
    if type == :separate_lines
      # multiple items on separate lines
      str = ""
      hit[key].each_with_index do |item, i|
        str += "<tr #{cls}>\n"
        str += "\t<td class='search_result_data_label' valign='top'>"
        str += label + ":" if i < 1
        str += "</td>\n"
        str += "\t<td valign='top' width='100%'>"
        str += h(item)
        str += "</td>\n"
        str += "</tr>\n"
      end

    elsif type == :single_item
      # single item
      str = "<tr #{cls}>\n"
      str += "\t<td class='search_result_data_label' valign='top'>"
      str += label + ":"
      str += "</td>\n"
      str += "\t<td valign='top' width='100%'>"
      str += h(hit[key])
      str += "</td>\n"
      str += "</tr>\n"

    elsif type == :multiple_item
      # multiple item, one line
      str = "<tr #{cls}>\n"
      str += "\t<td class='search_result_data_label' valign='top'>"
      str += label + ":"
      str += "</td>\n"
      str += "\t<td valign='top' width='100%'>"
      str += h(hit[key].join('; '))
      str += "</td>\n"
      str += "</tr>\n"
    end
    return str
  end
  
  ##############################
  # Helpers for the facet tree that shows resources
  # These are called either in edit mode or normal mode
  # For the administrator page or the search page.
  def site_selector(site, indent, is_edit_mode, is_category, parent_id, start_hidden, is_found, is_open, site_count )
    display_name = h(site.display_name)
    id = site.id
    value = site['value']
    
    # This is one line in the resources.
    # If edit mode: don't show # objects, show value instead.
    # if category, put in arrow for expand/collapse
    html = "<tr id='resource_#{site.id}' class='#{'resource_node ' if is_category}#{parent_id}#{ ' hidden' if start_hidden }#{ ' limit_to_selected' if site_is_in_constraints?(value) }'><td class='limit_to_lvl#{indent}'>\n"
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
          html += display_name + "&nbsp;&nbsp;" + link_to('[X]', { :controller => 'search', :action =>'constrain_resource', :resource => value, :remove => 'true'}, { :class => 'modify_link' }) + "</td><td class='num_objects'>#{number_with_delimiter(total)}"
        else
          link = link_to(display_name, {:controller=>"search", :action => 'constrain_resource', :resource => value }, { :method => :post, :class => 'nav_link' })
          html += "#{link}</td><td class='num_objects'>#{number_with_delimiter(total)}"
        end
      end
    end
    html += "</td></tr>\n"
    return html
  end

	def federation_selector(federation)
		html = "<tr><td>"
		selection = has_federation_constraint?(federation) ? "checked='checked'" : ''
		html += "<input type='checkbox' name='#{federation}' onchange='changeFederation(this); return false;' #{selection}><img src='/images/#{SKIN}/federation_#{federation}_thumb.jpg' alt='#{federation}' /></input>"
		html += "</td></tr>"
		return html
	end
  
  def genre_selector( genre_data )
    if genre_data[:exists]
      html = "<tr class='limit_to_selected'><td>#{h genre_data[:value]}&nbsp;&nbsp;" + link_to('[X]', { :controller => 'search', :action =>'remove_genre', :value => genre_data[:value]}, { :class => 'modify_link' })
    else
      html = "<tr><td class='limit_to_lvl1'>" + link_to("#{h genre_data[:value]}", {:controller=>"search", :action => 'add_facet', :field => 'genre', :value => genre_data[:value]}, { :method => :post, :class => 'nav_link' })
    end
    html += "</td><td class='num_objects'>#{number_with_delimiter(genre_data[:count])}</td></tr>"
    return html
  end

  def free_culture_selector(count)
    if free_culture_is_in_constraints?
      html = "<tr class='limit_to_selected'><td>Free Culture Only&nbsp;&nbsp;" + link_to('[X]', { :controller => 'search', :action =>'constrain_freeculture', :remove => 'true'}, { :class => 'modify_link' })
    else
      html = "<tr><td class='limit_to_lvl1'>" + link_to("Free Culture Only", {:controller=>"search", :action => 'constrain_freeculture' }, { :method => :post, :class => 'nav_link' })
    end
    html += "</td><td class='num_objects'>#{number_with_delimiter(count)}</td></tr>"
    return html
  end

  def full_text_selector(count)
    if full_text_is_in_constraints?
      html = "<tr class='limit_to_selected'><td>Full Text Only&nbsp;&nbsp;" + link_to('[X]', { :controller => 'search', :action =>'constrain_fulltext', :remove => 'true'}, { :class => 'modify_link' })
    else
      html = "<tr><td class='limit_to_lvl1'>" + link_to("Full Text Only", {:controller=>"search", :action => 'constrain_fulltext' }, { :method => :post, :class => 'nav_link' })
    end
    html += "</td><td class='num_objects'>#{number_with_delimiter(count)}</td></tr>"
    return html
  end

#  def nines_selector(count)
#    if federation_is_in_constraints?('NINES')
#      html = "<tr class='limit_to_selected'><td>NINES&nbsp;&nbsp;" + link_to('[X]', { :controller => 'search', :action =>'remove_facet', :field => 'federation', :value => 'NINES'}, { :class => 'modify_link' })
#    else
#      html = "<tr><td class='limit_to_lvl1'>" + link_to("NINES", {:controller=>"search", :action => 'add_facet', :field => 'federation', :value => 'NINES' }, { :method => :post, :class => 'nav_link' })
#    end
#    html += "</td><td class='num_objects'>#{number_with_delimiter(count)}</td></tr>"
#    return html
#  end
#
#  def eighteenth_connect_selector(count)
#    if federation_is_in_constraints?('18thConnect')
#      html = "<tr class='limit_to_selected'><td>18th Connect&nbsp;&nbsp;" + link_to('[X]', { :controller => 'search', :action =>'remove_facet', :field => 'federation', :value => '18thConnect'}, { :class => 'modify_link' })
#    else
#      html = "<tr><td class='limit_to_lvl1'>" + link_to("18th Connect", {:controller=>"search", :action => 'add_facet', :field => 'federation', :value => '18thConnect' }, { :method => :post, :class => 'nav_link' })
#    end
#    html += "</td><td class='num_objects'>#{number_with_delimiter(count)}</td></tr>"
#    return html
#  end

	def format_name_facet(name, typ)
		name[0] = name[0].gsub("\"", "")
		return link_to("#{name[0]} (#{name[1]})", { :controller => 'search', :action => 'add_constraint', :search_type => typ,  :search_not => 'AND', :search => { :phrase => '', :notphrase => name[0]}, :from_name_facet => 'true' }, { :class => 'nav_link' })
	end

	def format_no_name_message(index, total)
		if index == 0 && total == 0
			return "<span class='no_names_msg'>No names were contributed for this category.</span>"
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
		return html
	end

	def facet_tree_selection_row(id, parent_id, indent_level, start_shown, label, num_objects, url, update_div, selected)
		html = "<tr id='resource_#{id}' class='child_of_#{parent_id}#{' hidden' if !start_shown}#{' limit_to_selected' if selected}'><td class='limit_to_lvl#{indent_level}'>"
		# If you want to post, use postLink(this.href) to POST instead of doing an ajax update.
		if selected
			html += "#{h(label)}&nbsp;<a href='#{url}' class='nav_link' onclick=\"ajaxWithProgressSpinner([ this.href ], [ '#{update_div}' ], { waitMessage: 'Removing Facet...' }, { }); return false;\">[X]</a>"
		else
			html += "<a href='#{url}' class='nav_link' onclick=\"ajaxWithProgressSpinner([ this.href ], [ '#{update_div}' ], { waitMessage: 'Adding Facet...' }, { }); return false;\">#{h(label)}</a>"
		end
		html += "</td><td class='num_objects'>#{num_objects}</td></tr>\n"
		return html
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
		tree.each{|node|
			label = node[:label]
			children = node[:children]
			total = 0
			children.each{|child_label, child_arr|
				total += count_children(child_arr)
			}

			html += facet_tree_node_row("#{id_base}-1", 0, 1, true, label, total, false)
			i = -2
			children.each{|child_label, child_arr|
				if child_arr.kind_of?(Array)
					html += facet_tree_node_row("#{id_base}#{i}", "#{id_base}-1", 2, false, child_label, count_children(child_arr), false)
					child_arr.each{|item|
						html += facet_tree_selection_row("#{id_base}#{item[:id]}", "#{id_base}#{i}", 3, false, item[:name], item[:count], "#{url_base}#{item[:id]}", update_div, item[:selected])
					}
					i -= 1
				else
					item = child_arr
					html += facet_tree_selection_row("#{id_base}#{item[:id]}", "#{id_base}#{-1}", 2, false, item[:name], item[:count], "#{url_base}#{item[:id]}", update_div, item[:selected])
				end
			}
		}
		return html
	end
end
