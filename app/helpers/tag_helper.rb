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

module TagHelper
  def tag_cloud(cloud_info, selection, controller, hide_some)
    str = ""
    is_hiding = false
    
    # get the buckets for the current zoom level
    zooms = cloud_info[:zoom_levels]
    zoom_level = 0
    if session[:tag_zoom]
       zoom_level = session[:tag_zoom] - 1
       zoom_level = 0 if zoom_level < 0 || zoom_level > 9
    end
    bucket_size = zooms[zoom_level]
    
    # generate a span tag for every item in the cloud. This tag will include a 
    # custom attribute 'zoom' that lists the zoom bucket that each tag should appear
    # in as zoom lvel changes. ex zoom='1,0,0,0,0,0,0,0,0,0' means that the tag 
    # appears in zoom level one but no others
    cloud_info[:cloud_freq].each_with_index do |item, i|
      tag_zoom_attribute = get_zoom_attribute(zooms,item.last)
      html = {}
      size = bucket_size[item.last]
      size = 0 if size.nil?
      if selection == item.first
        str += "<span #{tag_zoom_attribute} class='cloud#{size} sidebar_tag_link_selected'>#{raw(item.first)}</span>\n"
      else
        str += "<span #{tag_zoom_attribute} class='cloud#{size}'>#{link_to_tag(raw(item.first), item.last, false, controller, html)}</span>\n"
      end
      
      if hide_some && i == 25
        is_hiding = true
        str += "<div>#{link_to_function('[show entire tag cloud]', '$(\'more_tags\').show(); $(this).hide();', :id => 'more_tag_link', :class => 'nav_link dont_filter')}</div>\n"
        str += "<div id='more_tags' style='display:none;'>\n"
      end
    end
    
    if is_hiding
      str += "<br />#{link_to_function('[show fewer tags]', '$(\'more_tags\').hide(); $(\'more_tag_link\').show();', :class => 'nav_link dont_filter')}</div>\n"
    end
   return raw(str)
  end
  
  def create_total(view_type, total_hits, tag)
    if view_type == 'tag'
      encoded = encode_for_uri(h(tag))
      rss = "<a href='/tags/rss/#{encoded}.xml'>#{image_tag('RSS_icon.gif', { height: '16px', alt: 'RSS'})}</a>&nbsp;"
      return "#{rss}#{pluralize(total_hits, 'object')} tagged as \"#{h(tag).downcase}\". "
    elsif view_type == 'all_collected'
      return "#{pluralize(total_hits, 'object')} collected."
    elsif view_type == 'untagged'
      return "#{pluralize(total_hits, 'object does', 'objects do')} not have tags."
    end
  end

  def create_javascript_friendly_tag_name(tag_name)
    # This creates a string that can be passed to a javascript routine between single quotes.
    # It also takes care of html injection problems.
    tag_name = h(tag_name)
    # gsub tries to get fancy with the substitutions, so we'll trick it by changing the special characters first.
    tag_name = tag_name.gsub("\\", "\x02\x02")
    tag_name = tag_name.gsub("\x02", "\\")
    tag_name = tag_name.gsub("'", "\\\x03")
    tag_name = tag_name.gsub("\x03", "'")
    return tag_name
  end
  
  private
  # +value+ has any ampersands changed to +&amp;+
  def link_to_tag(value, frequency, show_freq, controller, html_options = {})
     if frequency
        html_options[:title] = pluralize(frequency, 'object')
     end
     #amped_value = value.gsub(/&amp;/, "&").gsub(/&/, "&amp;").gsub(/ \/ \/ \*$/, "")
     escaped_value = h(value)
     if show_freq
       visible = "#{escaped_value}&nbsp;(#{frequency})"
     else
       visible = escaped_value
     end
     html_options[:class] = 'nav_link'
	 #link = { :controller => controller, :action => 'results', :view => 'tag', :tag => escaped_value, :anchor => "top_of_results" }
	 link = "/#{controller}/results?view=tag&tag=#{escaped_value}#top_of_results"
     #raw(link_to(visible.downcase, link, html_options))
     raw(link_to_function(visible.downcase, "serverAction({action: { actions: '#{link}', params: {}}, progress: { waitMessage: 'Searching...' }, searching: true})", html_options))
  end
  
  # given a tag frequency and an zoom_data array containing [frequency][zoom_level]
  # return the attribute string containing all of the zoom levels for the freq
  def get_zoom_attribute(zoom_data, tag_frequency)
    attribute = "zoom='"
    zoom_data.each do | zoom |
      lvl = zoom[tag_frequency]
      lvl = 0 if lvl.nil?
      if attribute.length > 6
        attribute = attribute + ","
      end
      attribute = attribute + lvl.to_s()
    end  
    attribute = attribute + "'"
    return attribute
  end
end
