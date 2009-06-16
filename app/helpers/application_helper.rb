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

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def collex_version
    return "1.5.1"
  end
  
  def is_admin?
    user = session[:user]
    if user and user[:role_names].include? 'admin'
      return true
    end
    return false
  end

#  def yahoo_button(text, id, action)
#    "<a id='#{id}'>#{text}</a>\n" +
#    "<script type='text/javascript'>\n" +
#    "function button#{id}() { #{action}; return false; }\n" +
#    "var oButton = new YAHOO.widget.Button('#{id}', { type: 'link', onclick: { fn: button#{id} } });\n" +
#    "</script>\n"
#  end
  
  def switchClassesOnElement(el_str, class1, class2)
    # This returns the javascript to change a class in an element. It uses double quotes in the returned string.
    return "#{el_str}.addClassName(\"#{class1}\"); #{el_str}.removeClassName(\"#{class2}\");"
  end
  
  def result_button(text, id, action)
    "<a id='#{id}' onclick='#{action.gsub('\'', '"')}; return false;' />#{text}</a>"
    # "<input id='#{id}' type='button' value='#{text}' onclick='#{action.gsub('\'', '"')}; return false;' />"
  end
  
  def rounded_button(text, id, action, color)
#    return yahoo_button(text, id, action)
    enterHover = switchClassesOnElement("$(this).down()", "#{color}_rounded_button_left_hover", "#{color}_rounded_button_left") +
      switchClassesOnElement("$(this).down().down()", "#{color}_rounded_button_middle_hover", "#{color}_rounded_button_middle") +
      switchClassesOnElement("$(this).down().next()", "#{color}_rounded_button_right_hover", "#{color}_rounded_button_right")
    leaveHover = switchClassesOnElement("$(this).down()", "#{color}_rounded_button_left", "#{color}_rounded_button_left_hover") +
      switchClassesOnElement("$(this).down().down()", "#{color}_rounded_button_middle", "#{color}_rounded_button_middle_hover") +
      switchClassesOnElement("$(this).down().next()", "#{color}_rounded_button_right", "#{color}_rounded_button_right_hover")

    "<!--[if IE 6]>\n<div id='#{id}' class='ie6_rounded_button' onclick='#{action.gsub('\'', '"')}; return false;'>#{text}</div><![endif]-->\n" +
    "<!--[if gte IE 7]><!-->\n" +
    "<div id='#{id}' class='rounded_button_container' onmouseover='#{enterHover}' onmouseout='#{leaveHover}' onclick='#{action.gsub('\'', '"')}; return false;'><div class='#{color}_rounded_button_left'><div class='#{color}_rounded_button_middle'>\n" +
    "  <div class='rounded_button_top_spacing' ></div><span class='rounded_button_link'>#{text}</span>\n" +
    "</div></div><div class='#{color}_rounded_button_right'></div></div>" +
    "<!--<![endif]-->\n"
  end

  def rounded_h1(text)
    "<div class='rounded_left'><div class='rounded_middle'><div class='rounded_right'>\n" +
    "  <h1 class='rounded_h1'>#{text}</h1>\n" +
    "</div></div></div>"
  end

  def gradient_h1(text)
    "<div class='rounded_middle'><h1 class='rounded_h1'>#{text}</h1></div>"
  end
# looks like this was added into environments/development.rb
#   def nil.id() raise(ArgumentError, "You are calling nil.id!  This will result in '4'!") end   

  # enhances truncate() to strip any tags off. 
  # TODO should probably just override the built-in truncate, but need some alias_method_chain voodoo that doesn't work here.
  def truncate_no_tags(text, length=30, truncate_string="...")
    stripped = text.gsub(/<[^>]+>/, '')
    truncate(stripped, length, truncate_string)
  end
#This is a way for a page to tell the layout which page it is. It is used to draw the tabs correctly
  def current_page(text)
    content_for(:current_page) { text }
  end
  def current_sub_page(text)
    content_for(:current_sub_page) { text }
  end

private
  def make_curr_tab(label)
    "<td class='curr_tab'>#{label}</td>\n"
  end

  def make_link_tab(label, link)
    "<td class='link_tab'>#{link_to(label, link, { :class => 'nav_link' })}</td>\n"
  end

  def make_disabled_tab(label)
    "<td class='disabled_tab'>#{label}</td>\n"
  end

  public
  def link_separator
    return "&nbsp;|"
  end
  
  def draw_tabs(curr_page)
    tabs = [{ :name => 'HOME', :link => '/', :dont_show_yourself => true },
      { :name => 'News', :link => news_path + '/', :use_logo_style => true },
      { :name => 'Forum', :link => forum_path },
      { :name => 'Exhibits', :link => exhibit_list_path },
      { :name => 'Tags', :link => tags_path },
      { :name => 'Search', :link => search_path }
    ]
    
    # the my9s tab is separate, and is rendered first
    cls = (curr_page == 'My 9s') ? 'mynines_link_current' : 'mynines_link'
    html = "\t" + link_to('My 9s', my9s_path, { :class => cls }) + "\n"
    html += "\t" + "<div id='nav_container'>\n"
    tabs.each { |tab|
      if tab[:dont_show_yourself] && curr_page == tab[:name]
        # There's an exception: We don't want the home tab if we're on the home page
      else
        if tab[:use_logo_style] && curr_page == 'HOME'
          cls = 'tab_link_logo'
        else
          cls = (curr_page == tab[:name]) ? 'tab_link_current' : 'tab_link'
        end
        html += "\t\t" + link_to(tab[:name], tab[:link], { :class => cls }) + "\n"
      end
    }
    html += "\t" + "</div>\n"
  end

#Drawing the Tab control
#  def draw_tabs(curr_page)
#    # the items in the array are: [0]=displayed name, [1]=path, [2]=enabled?
#    tabs_arr = [ ['Home', "/", true],
#      ['My&nbsp;9s', my9s_path, true],
#      ['Search', search_path, true],
#      ['Tags', tags_path, true],
#      #['Discuss', forum_path, true],
#      ['Exhibits', exhibit_list_path, true],
#      ['News', news_path + '/', true],
#      ['About', tab_about_path, true]
#   ]
#  
#    html = ""
#    tabs_arr.each {|tab|
#      if (tab[2] == false)
#        html += make_disabled_tab(tab[0])
#      elsif (curr_page == tab[0])
#        html += make_curr_tab(tab[0])
#        session[:current_page] = params
#      else
#        html += make_link_tab(tab[0], tab[1])
#      end
#    }
#    return html
#  end
  
  # helper for adding default text if the property is blank
  def default_text(item, text)
    item.blank? ? text : item
  end

  # Rewritten version of Rails pluralize() helper that allows no number to be rendered
  def pluralize(count, singular, plural = nil, use_number = true)
    prefix = use_number ? "#{number_with_delimiter(count)} " : ""
      prefix + if count == 1 || count == '1'
      singular
    elsif plural
      plural
    elsif Object.const_defined?("Inflector")
      Inflector.pluralize(singular)
    else
      singular + "s"
    end
  end
  
  # Adds ability to use restful routes custom methods directly without passing in the :url
  # assumes an :update_(method) member of a mapped resource with a :post type, ie:
  # map.resources :exhibits, :member => { :update_title => :post }
  # which will generate a url like /exhibits/6;update_title
  def in_place_editor_field(object, method, tag_options = {}, in_place_editor_options = {})
    tag = ::ActionView::Helpers::InstanceTag.new(object, method, self)
    tag_options = {:tag => "span", :id => "#{object}_#{method}_#{tag.object.id}_in_place_editor", :class => "in_place_editor_field"}.merge!(tag_options)
    in_place_editor_options[:url] = in_place_editor_options[:url] || 
    eval("update_#{method}_#{object}_path(#{tag.object.id})") rescue url_for({ :action => "set_#{object}_#{method}", :id => tag.object.id })
    tag.to_content_tag(tag_options.delete(:tag), tag_options) +
    in_place_editor(tag_options[:id], in_place_editor_options)
  end
  
  def facet_label(field)
    label = case field
      when "archive"        then "sites"
      when "roles", "agent","agent_facet" then "names"
      when "username"       then "peers"
      when "year"           then "dates"
      when "tag", "", nil          then "keywords"
    else field.pluralize
    end

    label = RELATORS[field].downcase if field =~ /role_[A-Z]{3}/
  
    label
  end
  
  def thumbnail_image_tag(hit, options = {})
    thumb = CachedResource.get_thumbnail_from_hit(hit)
    image = CachedResource.get_image_from_hit(hit)
    progress_id = "progress_#{hit['uri']}"
    str = tag "img", options.merge({:alt => hit['title'], :src => get_image_url(thumb), :id => "thumbnail_#{hit['uri']}", :class => 'result_row_img hidden', :onload => "finishedLoadingImage('#{progress_id}', this, 100, 100);" })
    if image != thumb
      str = "<a class='nines_pic_link' onclick='showInLightbox(\"#{image}\", \"thumbnail_#{hit['uri']}\"); return false;' href='#'>#{str}</a>"
    end
    str = "<img id='#{progress_id}' class='result_row_img_progress' src='/images/ajax_loader.gif' alt='loading...' />\n" + str
    return str
  end

  # +value+ has any ampersands changed to +&amp;+
  def link_to_list(type, value, frequency=nil, html_options = {})
     if frequency
        html_options[:title] = pluralize(frequency, 'object')
     end
     display = value
     if (type=="archive")
       display = site(value) ? site(value)['description'] : value
     end
     amped_value = value.gsub(/&amp;/, "&").gsub(/&/, "&amp;").gsub(/ \/ \/ \*$/, "")
     target = sidebar_list_path(:type => type, :value => amped_value, :user => params[:user])
     link_to_function display, update_sidebar(target), html_options
  end
  
  def update_sidebar( target )
     %Q{sidebarTagCloud.updateSidebar("#{target}")}
  end
  
  def nbpluralize(count, singular, plural = nil)
     pluralize(count, singular, plural).gsub(/ /,'&nbsp;')
  end
  
  def link_to_popup(label, options, html_options={})
    html_options[:class] = 'nav_link'
    link_to_function(label, "popUp('#{url_for(options)}')", html_options)
  end
  
  def link_to_confirm(title, params, confirm_title, confirm_question)
    link_to title, params, { :post => true, :class => 'modify_link', :onclick => "new ConfirmLinkDlg(this, '#{confirm_title}', '#{confirm_question}'); return false;" }
  end
  
  def text_field_with_suggest(object, method, tag_options = {}, completion_options = {})
     (completion_options[:skip_style] ? "" : auto_complete_stylesheet) +
     text_field(object, method, tag_options) +
     content_tag("div", "", :id => "#{object}_#{method}_auto_complete", :class => "auto_complete") +
     auto_complete_field("#{object}_#{method}", { :url => { :controller=>"search", :action => "auto_complete_for_#{object}_#{method}" } }.update(completion_options))
  end
  
  def comma_separate(array)
    if array
      array.join(', ')
    else
      ""
    end
  end
  
  def site(code)
    Site.find_by_code(code) || { 'description' => code }
  end
  
  def pie_by_percent(percentage)
    %Q~<img src="/images/pie_#{percentage}.png" title="header=[#{percentage} per cent] body=[of the whole, given your current constraints] cssheader=[boxheader2] cssbody=[boxbody] fade=[on]"/>~
  end
  
  def pie(amount, total)
    #TODO renable pie.. disabled for performance testing 
    #pie_by_percent((100 * amount).quo(total.to_i).ceil)
  end
  
  def link_to_exhibit()
    if request.path =~ /exhibits/
      link_to "CREATE", intro_exhibits_path, :title => "header=[you are here] body=[search &amp; browse user-created content, or create and publish your own online exhibits]  cssheader=[boxheader2] cssbody=[boxbody] fade=[on]", :class => "active"
    else
      link_to "CREATE", intro_exhibits_path, :title => "header=[contribute] body=[search &amp; browse user-created content, or create and publish your own online exhibits]  cssheader=[boxheader2] cssbody=[boxbody] fade=[on]"
    end
  end
  
  def link_to_collect()
    if request.path =~ /collex/
      link_to "RESEARCH", {:controller => "search"}, :title => "header=[you are here] body=[locate, collect, and annotate digital resources]  cssheader=[boxheader2] cssbody=[boxbody] fade=[on]", :class => "active"
    else
      link_to "RESEARCH", {:controller => "search"}, :title => "header=[research] body=[locate, collect, and annotate digital resources]  cssheader=[boxheader2] cssbody=[boxbody] fade=[on]"
    end
  end
  
  def escape_for_xml(obj)
    # This either gets a string passed to it or an array of strings
    if obj.kind_of?(Array)
      str = ""
      obj.each do |s|
        str += s + ' '
      end
    else
      str = obj
    end
    
    return "" if str == nil

    str = str.gsub('&', '&amp;')
    str = str.gsub('<', '&lt;')
    str = str.gsub('>', '&gt;')
    str = str.gsub('"', '&quot;')
    str = str.gsub("'", '&apos;')
    return str
  end
  
  def decode_exhibit_links(text)
    # This routine turns our special <span> into a standard <a>
    #<span class="ext_linklike" real_link="xxx" title="NINES Object: xxx">yyy</span>
    # becomes:
    #<a href="http://xxx" target="_blank">yyy</a>

    return text if text == nil || text == ''

    # find all the spans
    span_str = '<span'
    arr = text.split(span_str)
    return text if arr.length == 1
    
    str = arr[0]  # the first element has everything before the first span, so we just start with that.
    is_first = true
    for span in arr
      if is_first
        is_first = false  # skip the first section since we dealt with it above.
      else
        if span.include?('class="nines_linklike') #if it is one of our spans, then translate it into a link
          # nines object type link. Convert the uri into a url
          uri = extract_link_from_encoded_span(span)
          url = CachedResource.get_link_from_uri(uri)
          visible_text = extract_inner_html(span)
          rest_of_it = extract_trailing_html(span)
          str += "<a class='nines_link' href=\"#{url}\" target=\"_blank\">#{visible_text}</a>#{rest_of_it}"
          
        elsif span.include?('class="ext_linklike') #if it is one of our spans, then translate it into a link
          # external link
          url = extract_link_from_encoded_span(span)
          url = "http://" + url if url.index("http://") != 0
          visible_text = extract_inner_html(span)
          rest_of_it = extract_trailing_html(span)
          str += "<a class='ext_link' href=\"#{url}\" target=\"_blank\">#{visible_text}</a>#{rest_of_it}"
        else
          # Not one of our spans, so just stitch it back together
          str += span_str + span
        end
      end
    end
    return str
  end
  
  # Some private convenience functions to make the above routine clearer
  def extract_link_from_encoded_span(span)
    el= span.split('>', 2)  # find the end of the opening part of the span tag.
    arr = el[0].split('real_link="', 2)
    return "" if arr.length < 2
    arr2 = arr[1].split('"')
    return arr2[0]
  end
  
  def extract_inner_html(span)
    el = span.split('>', 2)  # find the end of the opening part of the span tag.
    return "" if el.length < 2
    
    el2 = el[1].split('</span>')
    return "" if el2.length == el[1].length
    
    return el2[0]
  end
  
  def extract_trailing_html(span)
    el = span.split('</span>', 2)
    return "" if el.length < 2
    
    return el[1]
  end
end
