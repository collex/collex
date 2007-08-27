# The methods added to this helper will be available to all templates in the application.
module ApplicationHelper
# looks like this was added into environments/development.rb
#   def nil.id() raise(ArgumentError, "You are calling nil.id!  This will result in '4'!") end   

  # Rewritten version of Rails pluralize() helper that allows no number to be rendered
  def pluralize(count, singular, plural = nil, use_number = true)
    prefix = use_number ? "#{count} " : ""
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
  
  # Adds abilitity to use restful routes custom methods directly without passing in the :url
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
  

  def show_hide_link_to(options={})
    options = options.symbolize_keys
    options = {:show_label => "show", :hide_label => "hide", :hidden_element => "hidden", :id_suffix => ""}.update(options)
    show_result = capture do
      link_to_function(options[:show_label], nil, :id => "show" + options[:id_suffix]) do |page|
        page.show options[:hidden_element], "hide#{options[:id_suffix]}"
        page.hide "show#{options[:id_suffix]}"
      end
    end
    hide_result = capture do
      link_to_function(options[:hide_label], nil, :id => "hide" + options[:id_suffix], :style => "display:none") do |page|
        page.hide options[:hidden_element], "hide#{options[:id_suffix]}"
        page.show "show#{options[:id_suffix]}"
      end
    end
    show_result + hide_result
  end

  def cloud_list
    ["archive", "agent", "year", "tag", "genre", "username"]
  end
  
  def cloud_list_links
    cloud_list.collect { |name| link_to_cloud name }.join(" ")
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
  
  def thumbnail_image_tag(item, options = {})
    if item.kind_of?(Hash)
      options = {:align => 'left'}.merge(options)
      site_thumbnail = site(item['archive']).thumbnail.strip rescue ''
      site_url = site_thumbnail.length > 0 ? site_thumbnail : false
      item_thumbnail = item['thumbnail'].strip rescue ''
      item_url = item_thumbnail.length > 0 ? item_thumbnail : false
      path = item_url ? item_url : (site_url ? site_url : DEFAULT_THUMBNAIL_IMAGE_PATH)
      tag "img", options.merge({:alt => item['title'], :src => path, :id => "thumbnail_#{item['uri']}"})
    else  
      options = {:align => 'left'}.merge(options)
      site_thumbnail = site(item.archive).thumbnail.strip rescue ''
      site_url = site_thumbnail.length > 0 ? site_thumbnail : false
      item_thumbnail = item.thumbnail.strip rescue ''
      item_url = item_thumbnail.length > 0 ? item_thumbnail : false
      path = item_url ? item_url : (site_url ? site_url : DEFAULT_THUMBNAIL_IMAGE_PATH)
      tag "img", options.merge({:alt => item.title, :src => path, :id => "thumbnail_#{item.uri}"})
    end
  end

  def link_to_list(type, value, frequency=nil)
     html_options = {}
     if frequency
        html_options[:title] = pluralize(frequency, 'object')
     end
     display = value
     if (type=="archive")
       display = site(value) ? site(value)['description'] : value
     end
     link_to_remote display, {:update => "sidebar", :url => sidebar_list_path(:type => type, :value => value, :user => params[:user])}, html_options
  end
  
  def nbpluralize(count, singular, plural = nil)
     pluralize(count, singular, plural).gsub(/ /,'&nbsp;')
  end
  
  def link_to_popup(label, options, html_options={})
    link_to_function(label, "popUp('#{url_for(options)}')", html_options)
  end
  
  def link_to_cloud(type, label=type)
    css_class = params[:type] == type ? "selected" : ""
    link_to_remote facet_label(label), {:update => "sidebar",
        :url => sidebar_cloud_path(:user => params[:user], :type => type)}, 
        {:class => css_class}
  end
  
  def link_to_peer(user, count)
    link_to_remote user, {:update=>"sidebar", :url => sidebar_cloud_path(:type => "tag", :user => user)}, {:title => pluralize(count, 'object')}
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
    Site.find_by_code(code)
  end
  
  def pie_by_percent(percentage)
    %Q~<img src="/images/pie_#{percentage}.png" title="header=[#{percentage} per cent] body=[of the whole, given your current constraints] cssheader=[boxheader2] cssbody=[boxbody] fade=[on]"/>~
  end
  
  def pie(amount, total)
    pie_by_percent((100 * amount).quo(total.to_i).ceil)
  end
  
  def link_to_exhibit()
    if request.path =~ /exhibits/
      link_to "CREATE", exhibits_path, :title => "header=[you are here] body=[search &amp; browse user-created content, or create and publish your own online exhibits]  cssheader=[boxheader2] cssbody=[boxbody] fade=[on]", :class => "active"
    else
      link_to "CREATE", exhibits_path, :title => "header=[contribute] body=[search &amp; browse user-created content, or create and publish your own online exhibits]  cssheader=[boxheader2] cssbody=[boxbody] fade=[on]"
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
