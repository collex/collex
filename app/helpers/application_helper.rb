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

# The methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def collex_version
    return "1.4.7.2"
  end
  
  def is_admin?
    user = session[:user]
    if user and user[:role_names].include? 'admin'
      return true
    end
    return false
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

private
  def make_curr_tab(label)
    "<td class='curr_tab'>#{label}</td>\n"
  end

  def make_link_tab(label, link)
    "<td class='link_tab'>#{link_to label, link }</td>\n"
  end

  def make_disabled_tab(label)
    "<td class='disabled_tab'>#{label}</td>\n"
  end

  public
  def link_separator
    return "&nbsp;|"
  end
#Drawing the Tab control
  def draw_tabs(curr_page)
    # the items in the array are: [0]=displayed name, [1]=path, [2]=enabled?, [3]=logged in only?
    tabs_arr = [ ['Home', "/", true, false],
      ['My&nbsp;9s', my9s_path, true, false],
      ['Search', search_path, true, false],
      ['Tags', tags_path, true, false],
      ['Exhibits', exhibit_list_path, true, false],
      ['News', news_path, true, false],
      ['About', tab_about_path, true, false]
   ]
  
    html = ""
    tabs_arr.each {|tab|
      if (tab[3] == false || is_logged_in?)
        if (tab[2] == false)
          html += make_disabled_tab(tab[0])
        elsif (curr_page == tab[0])
          html += make_curr_tab(tab[0])
          logout_path = (tab[3] == false) ? tab[1] : tabs_arr[0][1]
          session[:current_page] = [ tab[1], logout_path ]
        else
          html += make_link_tab(tab[0], tab[1])
        end
      end
    }
    return html
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
    options = {:align => 'left'}.merge(options)
    thumb = CachedResource.get_thumbnail_from_hit(hit)
    image = CachedResource.get_image_from_hit(hit)
    str = tag "img", options.merge({:alt => hit['title'], :src => get_image_url(thumb), :id => "thumbnail_#{hit['uri']}"})
    if image != thumb
      str = "<a onclick='showInLightbox(\"#{image}\"); return false;' href='#'>#{str}</a>"
    end
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
    link_to_function(label, "popUp('#{url_for(options)}')", html_options)
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
end
