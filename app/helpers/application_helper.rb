# The methods added to this helper will be available to all templates in the application.
module ApplicationHelper
# looks like this was added into environments/development.rb
#   def nil.id() raise(ArgumentError, "You are calling nil.id!  This will result in '4'!") end   

  def facet_label(field)
    label = case field
      when "archive"        then "site"
      when "roles", "agent" then "name"
      when "username"       then "peer"
      when "year"           then "date"
      when "", nil          then "tag"
    else field
    end

    label = RELATORS[field].downcase if field =~ /role_[A-Z]{3}/
  
    label
  end
  
  def thumbnail_image_tag(item, options = {})
    options = {:align => 'left'}.merge(options)
    site_thumbnail = site(item['archive']).thumbnail.strip rescue ''
    site_url = site_thumbnail.length > 0 ? site_thumbnail : false
    item_thumbnail = item['thumbnail'].strip rescue ''
    item_url = item_thumbnail.length > 0 ? item_thumbnail : false
    path = item_url ? item_url : (site_url ? site_url : DEFAULT_THUMBNAIL_IMAGE_PATH)
    tag "img", options.merge({:alt => item['title'], :src => path})
  end

  def is_logged_in?
    session[:user] ? true : false
  end

  def me?
    session[:user] ? (params[:user] == session[:user][:username]) : false
  end

  def username
    session[:user] ? session[:user][:username] : nil
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
     link_to_remote display, {:update => "sidebar", :url => {:controller => 'sidebar', :action => 'list', :params => {:type => type, :value => value, :user => params[:user]}}}, html_options
  end
  
  def nbpluralize(count, singular, plural = nil)
     pluralize(count, singular, plural).gsub(/ /,'&nbsp;')
  end
  
  def link_to_popup(label, options, html_options={})
    link_to_function(label, "popUp('#{url_for(options)}')", html_options)
  end
  
  def link_to_cloud(type, label=type)
    if params[:type] == type
      facet_label(label)
    else
      link_to_remote facet_label(label), :update => "sidebar",
          :url => { :controller => 'sidebar', :action => 'cloud', :params=> {:user => params[:user], :type => type} }
    end
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
    Site.for_code(code)
  end
end
