module TagHelper
  def tag_cloud(list, bucket_size, all_tags)
    xm = Builder::XmlMarkup.new(:indent => 2)
    list.each do |item|
#        html = (i > NUM_VISIBLE_TAGS) ? { :style => "display:none;" } : {}
      html = {}
      xm.span :class => "cloud#{item.last.quo(bucket_size).ceil}" do
        xm << link_to_tag(item.first, item.last, all_tags, false, html)
      end
    end
    return xm
  end
  
  def tag_list(list, all_tags, selection)
    xm = Builder::XmlMarkup.new(:indent => 2)
    list.each do |item|
      html = {}
      if selection == item.first
        xm.div :class => "sidebar_tag_link_selected" do
          xm << "#{item.first} (#{item.last})"
        end
      else
        xm.div :class => "sidebar_tag_link" do
          xm << link_to_tag(item.first, item.last, all_tags, true, html)
        end
      end
    end
    return xm
  end
  
  private
  # +value+ has any ampersands changed to +&amp;+
  def link_to_tag(value, frequency, all_tags, show_freq, html_options = {})
     if frequency
        html_options[:title] = pluralize(frequency, 'object')
     end
     amped_value = value.gsub(/&amp;/, "&").gsub(/&/, "&amp;").gsub(/ \/ \/ \*$/, "")
     value = "#{value} (#{frequency})" if show_freq
     link_to value, { :action => 'results', :view => 'tag', :tag => amped_value, :all_tags=> all_tags }, html_options
  end
end
