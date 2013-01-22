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

module MyCollexHelper
  def down_char
    raw("&darr;")
  end
  def up_char
    raw("&uarr;")
  end
  def del_char
    raw("&times;")
  end
  def ins_char
    raw("&crarr;")
  end
  def change_char
    raw("&Delta;")
  end
  def left_char
    raw("&larr;")
  end
  def right_char
    raw("&rarr;")
  end
  def element_bullet
    raw("&para;")
  end
  def opened_char
    raw('&#x25BC;')
  end
  def closed_char
    raw('&#x25B2;')
  end
  
  def element_text_thumbnail(text)
    if text == nil || text.length == 0
      return "[no text]"
    end
    
    text = strip_tags(text)
    if text.length < 30
      return text
    else
      return text[0..29] + "..."
    end
  end
  
  def element_pic_thumbnail(element, pos)
    illustrations = element.exhibit_illustrations
    if illustrations.length > pos
      element_pic_thumbnail_illustration(illustrations[pos])
    else
      raw("<img src='#{get_image_url(nil)}' height='16px' />")
    end
  end
  
  def get_image_url(url)
    if url == nil || url.length == 0
      return image_path(DEFAULT_THUMBNAIL_IMAGE_PATH)
    end
    return url
  end

	def get_url_for_internal_image(image, ty = nil)
		# image is the item in the database that points to the image.
		# ty is :micro, :smaller, :thumb
		return "" if image == nil
		return "" if image.photo.url == nil
		return "/#{image.photo.url(ty)}" if ty
		return "/#{image.photo.url()}"
	end

  def element_pic_thumbnail_illustration(illustration)
    if illustration.illustration_type == ExhibitIllustration.get_illustration_type_image()
      raw("<img src='#{get_image_url(illustration.image_url)}' height='16px' />")
    elsif illustration.illustration_type == ExhibitIllustration.get_illustration_type_nines_obj()
      thumb = CachedResource.get_thumbnail_from_uri(illustration.nines_object_uri)
      raw("<img src='#{get_image_url(thumb)}' height='16px' />")
    elsif illustration.illustration_type == ExhibitIllustration.get_illustration_type_text()
      "..."
    end
  end

  def tree_node( page_num, item_id_prefix, class_name, toggle_function, exhibit_id, num_pages, initial_state )
    display_none = 'style="display:none"'
    label = ""
    if num_pages > 1  # We don't want any page controls if there is only one page.
      label << "<div class='outline_right_controls'>\n"
      if page_num.to_i > 1
        label << link_to_function(up_char(), "doAjaxLinkOnPage('move_page_up', #{exhibit_id}, #{page_num} );", { :title => 'Move Page Up', :class => 'modify_link' }) + "\n"
      end
      if page_num.to_i < num_pages
        label << link_to_function(down_char(), "doAjaxLinkOnPage('move_page_down', #{exhibit_id}, #{page_num} );", { :title => 'Move Page Down', :class => 'modify_link' }) +"\n"
      end
      label << '&nbsp;<span class="close_link">'
      label << link_to_function(del_char(), "doAjaxLinkOnPage('delete_page', #{exhibit_id}, #{page_num} );", { :title => 'Delete Page', :class => 'modify_link' })
      label << "</span>\n"
      label << "</div>\n"
    end
    
    label << "<span id=\"#{item_id_prefix}_p#{page_num}_closed\" #{initial_state == :open ? display_none : ''} >"
    label << link_to_function(closed_char(),"#{toggle_function}('#{item_id_prefix}_p#{page_num}')", { :class => 'modify_link' })
    label << "</span>\n"
    label << "<span id=\"#{item_id_prefix}_p#{page_num}_opened\" #{initial_state == :closed ? display_none : ''} >"
    label << link_to_function(opened_char(), "#{toggle_function}('#{item_id_prefix}_p#{page_num}')", { :class => 'modify_link'})
    label << "</span>\n"
    label << "<span class='#{class_name}'>" + "Page " + page_num + "</span>\n"
	return raw(label)
  end  
  
  def create_border_div(element, border_active, border_class)
    # This creates either an open div tag with a border, nothing, or a close div tag .
    # If this is the first element in a section, then is_first is returned true .
    close_div = "</div>\n"
    open_div = "<div class='#{border_class}'>\n"
    border_type = element.get_border_type()
    if border_type == "start_border" && border_active == true
      html = close_div + open_div
      border_active = true
      #is_first = true
    elsif border_type == "start_border" && border_active == false
      html = open_div
      border_active = true
      #is_first = true
    elsif border_type == "continue_border" && border_active == true
      html = ""
      border_active = true
      #is_first = false
    elsif border_type == "continue_border" && border_active == false
      html = open_div
      border_active = true
      #is_first = true
    elsif border_type == "no_border" && border_active == true
      html = close_div
      border_active = false
      #is_first = true
    elsif border_type == "no_border" && border_active == false
      html = ""
      border_active = false
      #is_first = true
    end
    
    return { :border_active => border_active, :html => raw(html) }
  end

	def exhibit_builder_style_name(exhibit)
		if exhibit.fonts_match_defaults()
			return "#{Setup.site_name()} default"
		else
			return "Custom style"
		end
	end
end
