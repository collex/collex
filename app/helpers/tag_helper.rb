module TagHelper
  def tag_cloud(list, bucket_size)
    xm = Builder::XmlMarkup.new(:indent => 2)
    list.each do |item|
#        html = (i > NUM_VISIBLE_TAGS) ? { :style => "display:none;" } : {}
      html = {}
      xm.span :class => "cloud#{item.last.quo(bucket_size).ceil}" do
        xm << link_to_tag(item.first, item.last, html)
      end
    end
    return xm
  end
  
  # +value+ has any ampersands changed to +&amp;+
  def link_to_tag(value, frequency=nil, html_options = {})
     if frequency
        html_options[:title] = pluralize(frequency, 'object')
     end
     display = value
     amped_value = value.gsub(/&amp;/, "&").gsub(/&/, "&amp;").gsub(/ \/ \/ \*$/, "")
     link_to display, { :action => 'results', :view => 'tag', :tag => amped_value }, html_options
  end
end
