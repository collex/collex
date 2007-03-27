module ExhibitsHelper
  def exhibit_in_place_editor_field(object, method, tag_options = {}, in_place_editor_options = {}, external_control_options = {})
        
    tag = ::ActionView::Helpers::InstanceTag.new(object, method, self)
    tag_options = {:tag => "span", :id => "#{object}_#{method}_#{tag.object.id}_in_place_editor", :class => "in_place_editor_field"}.merge(tag_options)
    
    in_place_editor_options[:url] ||= 
    eval("update_#{method}_#{object}_path(#{tag.object.id})") rescue url_for({ :action => "set_#{object}_#{method}", :id => tag.object.id })
    in_place_editor_options[:external_control] ||= "#{object}_#{method}_#{tag.object.id}_external_control"
    in_place_editor_options[:save_text] ||= "save #{object.to_s.humanize.downcase} #{method.to_s.humanize.downcase}"
    in_place_editor_options[:saving_text] ||= "saving #{object.to_s.humanize.downcase} #{method.to_s.humanize.downcase}..."
    in_place_editor_options[:size] ||= 35
    
    external_control_options = { :text => "edit #{object.to_s.humanize.downcase} #{method.to_s.humanize.downcase}", :class => "exhibit_external_control", :href => "javascript: void(0);", :id => in_place_editor_options[:external_control] }.merge(external_control_options)
    
#     tag.to_content_tag(tag_options.delete(:tag), tag_options) + "&nbsp;" +    
    value = tag.value(tag.object).blank? ? "(No #{method} given)" : tag.value(tag.object)
    tag.content_tag(tag_options.delete(:tag), value, tag_options) + "&nbsp;" +
    a(external_control_options.delete(:text), external_control_options) +
    in_place_editor(tag_options[:id], in_place_editor_options)
  end
  def exhibit_in_place_editor_area(object, method, tag_options = {}, in_place_editor_options = {}, external_control_options = {})
    in_place_editor_options[:rows] = 12
    in_place_editor_options[:cols] = 60
    exhibit_in_place_editor_field(object, method, tag_options, in_place_editor_options, external_control_options)
  end
  
  # Since Rails currently (1.2.1) does not generate proper URLs for nested resources without
  # the parent objects specified, this is a convenience
  def exhibited_section_in_place_editor_field(object, method, tag_options = {}, in_place_editor_options = {}, external_control_options = {})
    tag = ::ActionView::Helpers::InstanceTag.new(object, method, self)
    in_place_editor_options[:url] ||=  eval("update_#{method}_#{object}_path(#{tag.object.exhibit.id}, #{tag.object.id})") 
    exhibit_in_place_editor_field(object, method, tag_options, in_place_editor_options, external_control_options)
  end
  def exhibited_section_in_place_editor_area(object, method, tag_options = {}, in_place_editor_options = {}, external_control_options = {})
    in_place_editor_options[:rows] = 12
    in_place_editor_options[:cols] = 60
    exhibited_section_in_place_editor_field(object, method, tag_options, in_place_editor_options, external_control_options)
  end
  
  def exhibited_resource_in_place_editor_field(object, method, tag_options = {}, in_place_editor_options = {}, external_control_options = {})
    tag = ::ActionView::Helpers::InstanceTag.new(object, method, self)
    in_place_editor_options[:url] ||=  eval("update_#{method}_#{object}_path(#{tag.object.exhibited_section.exhibit.id}, #{tag.object.exhibited_section.id}, #{tag.object.id})") 
    exhibit_in_place_editor_field(object, method, tag_options, in_place_editor_options, external_control_options)
  end
  def exhibited_resource_in_place_editor_area(object, method, tag_options = {}, in_place_editor_options = {}, external_control_options = {})
    in_place_editor_options[:rows] = 12
    in_place_editor_options[:cols] = 60
    exhibited_resource_in_place_editor_field(object, method, tag_options, in_place_editor_options, external_control_options)
  end
end
