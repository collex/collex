module TagHelper
  def tag_cloud(list, bucket_size, selection, controller)
    str = ""
    list.each do |item|
      html = {}
      size = item.last.quo(bucket_size).ceil
      if selection == item.first
        str += "<span class='cloud#{size} sidebar_tag_link_selected'>#{h(item.first)}</span>\n"
      else
        str += "<span class='cloud#{size}'>#{link_to_tag(item.first, item.last, false, controller, html)}</span>\n"
       end
    end
    return str
#    xm = Builder::XmlMarkup.new(:indent => 2)
#    list.each do |item|
#      html = {}
#      size = item.last.quo(bucket_size).ceil
#      if selection == item.first
#        xm.span :class => "cloud#{size} sidebar_tag_link_selected" do
#          xm << "#{h(item.first)}"
#        end
#      else
#        xm.span :class => "cloud#{size}" do
#          xm << link_to_tag(item.first, item.last, false, controller, html)
#        end
#      end
#    end
#    return xm
  end
  
#  def tag_list(list, selection)
#    xm = Builder::XmlMarkup.new(:indent => 2)
#    if list == nil
#      return xm
#    end
#    list.each do |item|
#      html = {}
#      if selection == item.first
#        xm.div :class => "sidebar_tag_link_selected" do
#          xm << "#{h(item.first)}&nbsp;(#{item.last})"
#        end
#      else
#        xm.div :class => "sidebar_tag_link" do
#          xm << link_to_tag(item.first, item.last, true, html)
#        end
#      end
#    end
#    return xm
#  end

  def create_total(view_type, total_hits, tag)
    if view_type == 'tag'
      rss = "<a href='/tags/rss/#{tag}.xml'><img src='/images/RSS_icon.gif' height='16px' alt='RSS'/></a>&nbsp;"
      return "#{rss}#{pluralize(total_hits, 'object')} tagged as \"#{h(tag)}\". "
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
     link_to visible, { :controller => controller, :action => 'results', :view => 'tag', :tag => escaped_value, :anchor => "top_of_results" }, html_options
  end
end
