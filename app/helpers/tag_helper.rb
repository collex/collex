module TagHelper
  def tag_cloud(list, bucket_size)
    xm = Builder::XmlMarkup.new(:indent => 2)
    list.each do |item|
#        html = (i > NUM_VISIBLE_TAGS) ? { :style => "display:none;" } : {}
      html = {}
      xm.span :class => "cloud#{item.last.quo(bucket_size).ceil}" do
        xm << link_to_tag(item.first, item.last, false, html)
      end
    end
    return xm
  end
  
  def tag_list(list, selection)
    xm = Builder::XmlMarkup.new(:indent => 2)
    list.each do |item|
      html = {}
      if selection == item.first
        xm.div :class => "sidebar_tag_link_selected" do
          xm << "#{item.first} (#{item.last})"
        end
      else
        xm.div :class => "sidebar_tag_link" do
          xm << link_to_tag(item.first, item.last, true, html)
        end
      end
    end
    return xm
  end

  def create_total(view_type, total_hits, tag)
    if view_type == 'tag'
      return "#{pluralize(total_hits, 'object')} tagged as \"#{tag}\"."
    elsif view_type == 'all_collected'
      return "#{pluralize(total_hits, 'object')} collected."
    elsif view_type == 'untagged'
      return "#{pluralize(total_hits, 'object')} do not have tags."
    end
end

  private
  # +value+ has any ampersands changed to +&amp;+
  def link_to_tag(value, frequency, show_freq, html_options = {})
     if frequency
        html_options[:title] = pluralize(frequency, 'object')
     end
     amped_value = value.gsub(/&amp;/, "&").gsub(/&/, "&amp;").gsub(/ \/ \/ \*$/, "")
     value = "#{value} (#{frequency})" if show_freq
     link_to value, { :action => 'results', :view => 'tag', :tag => amped_value }, html_options
  end
end
