module ExhibitsHelper
  def move_exhibited_items_links(exhibited_item, options = {})
    options = {:sideways => false}.merge(options).symbolize_keys
    section = exhibited_item.exhibited_section
    page = section.exhibited_page
    exhibit = page.exhibit
    up_arrow = options[:sideways] ? "&larr;" : "&uarr;"
    down_arrow = options[:sideways] ? "&rarr;" : "&darr;"
    
    html = options[:sideways] ? "<span>" : "<p>"
    html << link_to("#{up_arrow}#{up_arrow}", move_to_top_exhibited_item_path(exhibit, page, section, exhibited_item), :method => "post")
    html << (options[:sideways] ? "&nbsp;" : "<br/>")
    html << link_to("#{up_arrow}", move_higher_exhibited_item_path(exhibit, page, section, exhibited_item), :method => "post")
    html << (options[:sideways] ? "&nbsp;&nbsp;" : "</p><p>")
    html << link_to("#{down_arrow}", move_lower_exhibited_item_path(exhibit, page, section, exhibited_item), :method => "post")
    html << (options[:sideways] ? "&nbsp;" : "<br/>")
    html << link_to("#{down_arrow}#{down_arrow}", move_to_bottom_exhibited_item_path(exhibit, page, section, exhibited_item), :method => "post")
    html << (options[:sideways] ? "</span>" : "<p/>")
    html
  end
  
  def move_exhibited_section_links(exhibited_section)
    page = exhibited_section.exhibited_page
    exhibit = page.exhibit
    
    html = ""
    html << link_to("&uarr;&uarr;", move_to_top_exhibited_section_path(:exhibit_id => exhibit, :id => exhibited_section, :page_id => page), :method => "post")
    html << "&nbsp;"
    html << link_to("&uarr;", move_higher_exhibited_section_path(:exhibit_id => exhibit, :id => exhibited_section, :page_id => page), :method => "post")
    html << "&nbsp;"
    html << link_to("&darr;", move_lower_exhibited_section_path(:exhibit_id => exhibit, :id => exhibited_section, :page_id => page), :method => "post")
    html << "&nbsp;"
    html << link_to("&darr;&darr;", move_to_bottom_exhibited_section_path(:exhibit_id => exhibit, :id => exhibited_section, :page_id => page), :method => "post")
    html
  end
  
  def move_exhibited_page_links(exhibited_page)
    exhibited_page
    exhibit = exhibited_page.exhibit
    
    html = ""
    html << link_to("&uarr;&uarr;", move_to_top_page_path(:exhibit_id => exhibit, :id => exhibited_page), :method => "post")
    html << "&nbsp;"
    html << link_to("&uarr;", move_higher_page_path(:exhibit_id => exhibit, :id => exhibited_page), :method => "post")
    html << "&nbsp;"
    html << link_to("&darr;", move_lower_page_path(:exhibit_id => exhibit, :id => exhibited_page), :method => "post")
    html << "&nbsp;"
    html << link_to("&darr;&darr;", move_to_bottom_page_path(:exhibit_id => exhibit, :id => exhibited_page), :method => "post")
    html
  end
  
  
  
  def exhibit_in_place_editor_field(object, method, tag_options = {}, in_place_editor_options = {}, external_control_options = {})
        
    tag = ::ActionView::Helpers::InstanceTag.new(object, method, self)
    tag_options = {:tag => "span", :id => "#{object}_#{method}_#{tag.object.id}_in_place_editor", :class => "in_place_editor_field"}.merge(tag_options)
    
    in_place_editor_options[:url] ||= 
    eval("update_#{method}_#{object}_path(#{tag.object.id})") rescue url_for({ :action => "set_#{object}_#{method}", :id => tag.object.id })
    in_place_editor_options[:saving_text] ||= "saving #{object.to_s.humanize.downcase} #{method.to_s.humanize.downcase}..."
    in_place_editor_options[:size] ||= 35
    
#     tag.to_content_tag(tag_options.delete(:tag), tag_options) + "&nbsp;" +    
    value = tag.value(tag.object).blank? ? "(No #{method} given)" : tag.value(tag.object)
    tag.content_tag(tag_options.delete(:tag), value, tag_options) + "&nbsp;" +
    in_place_editor(tag_options[:id], in_place_editor_options)
  end
  def exhibit_in_place_editor_area(object, method, tag_options = {}, in_place_editor_options = {}, external_control_options = {})
    in_place_editor_options[:rows] = 12
    in_place_editor_options[:cols] = 60
    exhibit_in_place_editor_field(object, method, tag_options, in_place_editor_options, external_control_options)
  end
  
  # Since Rails currently (1.2.1) does not generate proper URLs for nested resources without
  # the parent objects specified, this is a convenience
  # TODO refactore these methods into two dynamic methods. There's a lot of repetition here.
  def exhibited_page_in_place_editor_field(object, method, tag_options = {}, in_place_editor_options = {}, external_control_options = {})
    tag = ::ActionView::Helpers::InstanceTag.new(object, method, self)
    in_place_editor_options[:url] ||=  eval("update_#{method}_page_path(#{tag.object.exhibit.id}, #{tag.object.id})") 
    exhibit_in_place_editor_field(object, method, tag_options, in_place_editor_options, external_control_options)
  end
  def exhibited_page_in_place_editor_area(object, method, tag_options = {}, in_place_editor_options = {}, external_control_options = {})
    in_place_editor_options[:rows] = 12
    in_place_editor_options[:cols] = 60
    exhibited_page_in_place_editor_field(object, method, tag_options, in_place_editor_options, external_control_options)
  end
  
  def exhibited_section_in_place_editor_field(object, method, tag_options = {}, in_place_editor_options = {}, external_control_options = {})
    tag = ::ActionView::Helpers::InstanceTag.new(object, method, self)
    in_place_editor_options[:url] ||=  eval("update_#{method}_#{object}_path(#{tag.object.exhibited_page.exhibit.id}, #{tag.object.exhibited_page.id}, #{tag.object.id})") 
    exhibit_in_place_editor_field(object, method, tag_options, in_place_editor_options, external_control_options)
  end
  def exhibited_section_in_place_editor_area(object, method, tag_options = {}, in_place_editor_options = {}, external_control_options = {})
    in_place_editor_options[:rows] = 12
    in_place_editor_options[:cols] = 60
    exhibited_section_in_place_editor_field(object, method, tag_options, in_place_editor_options, external_control_options)
  end
  
  def exhibited_resource_in_place_editor_field(object, method, tag_options = {}, in_place_editor_options = {}, external_control_options = {})
    tag = ::ActionView::Helpers::InstanceTag.new(object, method, self)
    in_place_editor_options[:url] ||=  eval("update_#{method}_#{object}_path(#{tag.object.exhibited_section.exhibited_page.exhibit.id}, #{tag.object.exhibited_section.exhibited_page.id}, #{tag.object.exhibited_section.id}, #{tag.object.id})") 
    exhibit_in_place_editor_field(object, method, tag_options, in_place_editor_options, external_control_options)
  end
  def exhibited_resource_in_place_editor_area(object, method, tag_options = {}, in_place_editor_options = {}, external_control_options = {})
    in_place_editor_options[:rows] = 12
    in_place_editor_options[:cols] = 60
    exhibited_resource_in_place_editor_field(object, method, tag_options, in_place_editor_options, external_control_options)
  end
  
  # TODO clean this up, add error handling/reporting
  def exhibits_tiny_mce_in_place_editor(object, method, tag_options = {})
    tag = ::ActionView::Helpers::InstanceTag.new(object, method, self)
    mce_id = "mce_#{object}_#{tag.object.id}"
    text_id = "text_#{object}_#{tag.object.id}"
    update_id = text_id
    value = tag.object.__send__(method) || tag_options[:value] || "(No annotation given)"
    
    url = case object
    when :exhibited_item
      eval("update_#{method}_#{object}_path(#{tag.object.exhibited_section.exhibited_page.exhibit.id}, #{tag.object.exhibited_section.exhibited_page.id}, #{tag.object.exhibited_section.id}, #{tag.object.id})")
    when :exhibited_page
      eval("update_#{method}_page_path(#{tag.object.exhibit.id}, #{tag.object.id})")
    when :exhibit
      eval("update_#{method}_#{object}_path(#{tag.object.id})")
    end
    
    html = Builder::XmlMarkup.new(:indent => 2)
    html << span(value, :id => text_id, :onclick => "this.style.backgroundColor = '#ffffff';Element.show('#{mce_id}'); Element.hide('#{text_id}')", :onmouseover => "this.style.backgroundColor = '#ffff99'; this.title = 'Click to edit';", :onmouseout => "this.style.backgroundColor = '#ffffff';")
    html.div(:style => "display: none;", :id => mce_id) do
      html.p("Rich text editing is not supported in Safari. For rich text editing, we recommend a gecko-based browser such as FireFox or Camino.") if request.env['HTTP_USER_AGENT'].downcase.index('safari') != nil
      html << link_to_function("cancel", "Element.hide('#{mce_id}'); Element.show('#{text_id}')")
      html << form_remote_tag(:url => url, :class => "tiny-mce-on", :update => text_id, :complete => "Element.hide('#{mce_id}'); Element.show('#{text_id}')")
      html << text_area_tag(:value, value, :id => "text_area_#{object}_#{tag.object.id}", :class => "tiny-mce")
      html << hidden_field_tag(:update_id, update_id)
      html << "</form>"
    end
  end
  
  
  
  
end
