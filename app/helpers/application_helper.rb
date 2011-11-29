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
  def is_admin?
    user = session[:user]
    if user and user[:role_names].include? 'admin'
      return true
    end
    return false
  end

	def get_curr_user
    user = session[:user]
		return nil if user == nil
		return User.find_by_username(user[:username])
	end

	def get_curr_user_id
    user = session[:user]
		return nil if user == nil
		return User.find_by_username(user[:username]).id
	end

	def get_stylesheets(page, debug)
		# We can't roll up the YUI css because all the images are specified on relative paths.
		fnames = GetIncludeFileList.get_css(page)
		yui_path = Branding.yui_path()
		yui_list = ""
		fnames[:yui].each { |f|
			yui_list += '&amp;' if fnames[:yui][0] != f
			yui_list += "#{yui_path}#{f}.css"
		}
		html = "<link rel='stylesheet' type='text/css' href='http://yui.yahooapis.com/combo?#{yui_list}' />\n"
		if debug
			html += stylesheet_link_tag(fnames[:local], :media => "all")
			return raw(html)
		else
			html += stylesheet_link_tag("#{page.to_s()}-min", :media => "all")
			return raw(html)
		end
	end

	def get_javascripts(page, debug)
		fnames = GetIncludeFileList.get_js(page)
		yui_path = Branding.yui_path()
		yui_list = ""
		fnames[:yui].each { |f|
			yui_list += '&' if fnames[:yui][0] != f
			yui_list += "#{yui_path}#{f}.js"
		}
		if debug
			html = javascript_include_tag(fnames[:prototype]) + "\n"
			if yui_list.length > 0
				html += javascript_include_tag("http://yui.yahooapis.com/combo?#{raw(yui_list)}") + "\n"
			end
			html += javascript_include_tag(fnames[:local]) + "\n"
			return raw(html)
		else
			html = javascript_include_tag("prototype-min") + "\n"
			if yui_list.length > 0
				html += javascript_include_tag("http://yui.yahooapis.com/combo?#{raw(yui_list)}") + "\n"
			end
			html += javascript_include_tag("#{page.to_s()}-min") + "\n"
			return raw(html)
		end
	end

#  def yahoo_button(text, id, action)
#    "<a id='#{id}'>#{text}</a>\n" +
#    "<script type='text/javascript'>\n" +
#    "function button#{id}() { #{action}; return false; }\n" +
#    "var oButton = new YAHOO.widget.Button('#{id}', { type: 'link', onclick: { fn: button#{id} } });\n" +
#    "</script>\n"
#  end
  
  def switch_classes_on_element(el_str, class1, class2)
    # This returns the javascript to change a class in an element. It uses double quotes in the returned string.
    return "#{el_str}.addClassName(\"#{class1}\"); #{el_str}.removeClassName(\"#{class2}\");"
  end
  
  def result_button(text, id, action, visible)
    cls = visible ? "" : "class='hidden' "
    return raw("<a id='#{id}' #{cls}onclick=\"#{action.gsub("\"", "&quot;")}; return false;\" >#{text}</a>")
    # "<input id='#{id}' type='button' value='#{text}' onclick='#{action.gsub('\'', '"')}; return false;' />"
  end
  
	def unobtrusive_result_button(text, id, klass, attributes, visible)
		klass += " hidden" if !visible
		attr = ""
		attributes.each {|key, val|
			val = val.to_s
			attr += " #{key}=\"#{val.gsub("\"", "&quot;")}\""
		}
		return raw("<a id='#{id}' class=\"#{klass}\" #{attr}>#{text}</a>")
	end

  def rounded_button(text, id, action, color)
#    return yahoo_button(text, id, action)
    enter_hover = switch_classes_on_element("$(this).down()", "#{color}_rounded_button_left_hover", "#{color}_rounded_button_left") +
      switch_classes_on_element("$(this).down().down()", "#{color}_rounded_button_middle_hover", "#{color}_rounded_button_middle") +
      switch_classes_on_element("$(this).down().next()", "#{color}_rounded_button_right_hover", "#{color}_rounded_button_right")
    leave_hover = switch_classes_on_element("$(this).down()", "#{color}_rounded_button_left", "#{color}_rounded_button_left_hover") +
      switch_classes_on_element("$(this).down().down()", "#{color}_rounded_button_middle", "#{color}_rounded_button_middle_hover") +
      switch_classes_on_element("$(this).down().next()", "#{color}_rounded_button_right", "#{color}_rounded_button_right_hover")

    html = "<!--[if IE 6]>\n<div id='#{id}' class='ie6_rounded_button' onclick='#{action.gsub('\'', '"')}; return false;'>#{text}</div><![endif]-->\n" +
    "<!--[if gte IE 7]><!-->\n" +
    "<div id='#{id}' class='rounded_button_container' onmouseover='#{enter_hover}' onmouseout='#{leave_hover}' onclick='#{action.gsub('\'', '"')}; return false;'><div class='#{color}_rounded_button_left'><div class='#{color}_rounded_button_middle'>\n" +
    "  <div class='rounded_button_top_spacing' ></div><span class='rounded_button_link'>#{text}</span>\n" +
    "</div></div><div class='#{color}_rounded_button_right'></div></div>" +
    "<!--<![endif]-->\n"
	return raw(html)
  end

  def rounded_h1(text)
    html = "<div class='rounded_left'><div class='rounded_middle'><div class='rounded_right'>\n" +
    "  <h1 class='rounded_h1'>#{text}</h1>\n" +
    "</div></div></div>"
	return raw(html)
  end

  def gradient_h1(text)
    html = "<div class='rounded_middle'><h1 class='rounded_h1'>#{text}</h1></div>"
	return raw(html)
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
    return raw("&nbsp;|")
  end
  
  def draw_tabs(curr_page)
    tabs = [{ :name => 'HOME', :link => '/', :dont_show_yourself => true },
      { :name => 'News', :link => news_path + '/', :use_logo_style => true },
		{ :name => 'Classroom', :link => '/classroom', :use_long => true },
		{ :name => 'Community', :link => '/communities', :use_long => true },
		{ :name => 'Publications', :link => '/publications', :use_long => true },
      { :name => 'Search', :link => search_path }
    ]
    if COLLEX_PLUGINS['typewright']
		search = tabs.pop()
      tabs.push({ :name => 'TypeWright', :link => '/typewright/documents', :use_long => true })
		tabs.push(search)
    end

    # the my_collex tab is separate, and is rendered first
    cls = (curr_page == Setup.my_collex()) ? 'my_collex_link_current' : 'my_collex_link'
    html = "\t" + link_to(Setup.my_collex(), '/' + MY_COLLEX_URL, { :class => cls }) + "\n"
    html += "\t" + "<div id='nav_container'>\n"
    tabs.each { |tab|
      if tab[:dont_show_yourself] && curr_page == tab[:name]
        # There's an exception: We don't want the home tab if we're on the home page
      else
        if tab[:use_logo_style] && curr_page == 'HOME'
          cls = 'tab_link_logo'
		elsif tab[:use_long]
          cls = (curr_page == tab[:name]) ? 'tab_link_long_current' : 'tab_link_long'
		else
          cls = (curr_page == tab[:name]) ? 'tab_link_current' : 'tab_link'
        end
        html += "\t\t" + link_to(tab[:name], tab[:link], { :class => cls }) + "\n"
      end
    }
    html += "\t" + "</div>\n"
	return raw(html)
  end

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
  
#  def facet_label(field)
#    label = case field
#      when "archive"        then "sites"
#      when "roles", "agent","agent_facet" then "names"
#      when "username"       then "peers"
#      when "year"           then "dates"
#      when "tag", "", nil          then "keywords"
#    else field.pluralize
#    end
#
#    label = RELATORS[field].downcase if field =~ /role_[A-Z]{3}/
#
#    label
#  end
  
  def thumbnail_image_tag(hit, options = {})
    thumb = CachedResource.get_thumbnail_from_hit(hit)
    image = CachedResource.get_image_from_hit(hit)
    progress_id = "progress_#{hit['uri']}"
	  title = hit['title'] ? hit['title'] : "Image"
    str = tag "img", options.merge({:alt => title, :src => get_image_url(thumb), :id => "thumbnail_#{hit['uri']}", :class => 'result_row_img hidden', :onload => "finishedLoadingImage('#{progress_id}', this, 100, 100);" })
    if image != thumb
		title = title[0,60]+'...' if title.length > 62
		title = title.gsub("'", "&apos;")
		title = title.gsub('"', "\\\"")
      str = "<a class='nines_pic_link' onclick='showInLightbox({ title: \"#{title}\", img: \"#{image}\", spinner: \"#{PROGRESS_SPINNER_PATH}\", size: 500 }); return false;' href='#'>#{str}</a>"
    end
    str = "<img id='#{progress_id}' class='progress_timeout result_row_img_progress' src='#{PROGRESS_SPINNER_PATH}' alt='loading...' data-noimage='#{SPINNER_TIMEOUT_PATH}' />\n" + str
    return raw(str)
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
  
#  def link_to_popup(label, options, html_options={})
#    html_options[:class] = 'nav_link'
#    link_to_function(label, "popUp('#{url_for(options)}')", html_options)
#  end
  
  def link_to_confirm(title, params, confirm_title, confirm_question, method = nil)
	  if method
		  act_str = "{ method: '#{method}', url: this.href }"
	  else
		  act_str = "this.href"
	  end
    link_to title, params, { :post => true, :class => 'modify_link',
		:onclick => "serverAction({confirm: { title: '#{confirm_title}', message: '#{confirm_question}' }, action: { actions: #{act_str} }, progress: { waitMessage: 'Please Wait...' }}); return false;" }
  end
  
  def text_field_with_suggest(object, method, tag_options = {}, completion_options = {})
     result = (completion_options[:skip_style] ? "" : auto_complete_stylesheet) +
     text_field(object, method, tag_options) +
     content_tag("div", "", :id => "#{object}_#{method}_auto_complete", :class => "auto_complete") +
     auto_complete_field("#{object}_#{method}", { :url => { :controller=>"search", :action => "auto_complete_for_#{object}_#{method}" } }.update(completion_options))
     #result = result.gsub('paramName:', 'parameters:')
     return result
  end
  
  def comma_separate(array)
    if array
      array.join(', ')
    else
      ""
    end
  end
  
  def site(code)
    return Catalog.factory_create(false).get_archive(code) #Site.find_by_code(code) || { 'description' => code }
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

  def escape_apos(str)
	  return "" if str == nil || str.length == 0
	  str = str.gsub("\'") { |apos| "\\\'" }
	  return str.gsub("\"") { |apos| "\\\"" }
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

	def denature_footnote_links(text)
    return text if text == nil || text == ''
		text = text.gsub("onclick=\'var footnote = $(this).next(); new MessageBoxDlg", "onclick=\'return false; var footnote = $(this).next(); new MessageBoxDlg")
		return raw(text)
	end

	def remove_footnote_links(text)
    return text if text == nil || text == ''
		tag = "<a href=\"#\" onclick='var footnote = $(this).next(); new MessageBoxDlg(\"Footnote\", footnote.innerHTML); return false;' class=\"superscript\">@</a>"
		return text.gsub(tag, "")
	end

	def clean_header(text)
		# This removes any tags or footnotes from inside the header text
    return text if text == nil || text == ''
		text = text.gsub("<a href=\"#\" onclick='var footnote = $(this).next(); new MessageBoxDlg(\"Footnote\", footnote.innerHTML); return false;' class=\"superscript\">@<\/a>", "")
		text = text.gsub(/<span class="hidden">.*?<\/span>/, "")
		return strip_tags(text)
	end

  def decode_exhibit_links(text)
    # This routine turns our special <span> into a standard <a>
    #<span class="ext_linklike" real_link="xxx" title="#{SITE_NAME} Object: xxx">yyy</span>
    # becomes:
    #<a href="http://xxx" target="_blank">yyy</a>

    return text if text == nil || text == ''

    # find all the spans
    span_str = '<span'
    arr = text.split(span_str)
    return raw(text) if arr.length == 1
    
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
          str += "<a class='nines_link' href=\"#{url}\" target=\"_blank\" uri='#{uri}'>#{visible_text}</a>#{rest_of_it}"
          
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
    return raw(str)
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

	def make_select_control(id, options, curr_sel, callback)
		start = ""
		for option in options
			start = option[:name] if curr_sel == option[:value]
		end
		html = "<input type='button' class='hidden' id='#{id}' name='#{id}' value='#{start}'><select id='#{id}select' class='hidden'>\n"
		for option in options
			html += "<option value='#{option[:value]}'>#{option[:name]}</option>\n"
		end
		html += "</select></span>\n"
		html += "<script type=\"text/javascript\">\n"
		html += "var callback_#{id} = function(sel) { #{callback} };\n"
		html += "initializeSelectCtrl('#{id}', '#{curr_sel}', callback_#{id});\n"
		html += "</script>\n"
		return raw(html)
	end

	def create_breadcrumbs(crumbs, here)
		links = []
		crumbs.each {|crumb|
			links.push(link_to(crumb[:text], crumb[:url], { :class => 'nav_link' }))
		}
		links.push(here)
		html = "<div class=\"breadcrumbs\">\n"
		html += links.join('&nbsp;&nbsp;&gt;&nbsp;&nbsp;')
		html += "</div>\n"
		return raw(html)
	end
end
