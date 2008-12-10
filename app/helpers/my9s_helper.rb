module My9sHelper
  def down_char
    "&dArr;"
  end
  def up_char
    "&uArr;"
  end
  def del_char
    "&times;"
  end
  def ins_char
    "&crarr;"
  end
  def change_char
    "&Delta;"
  end
  def left_char
    "&lArr;"
  end
  def right_char
    "&rArr;"
  end
  def element_bullet
    "&para;"
  end
  def opened_char
    '&#x25BC;'
  end
  def closed_char
    '&#x25B2;'
  end
  
  def element_text_thumbnail(element)
    if element.element_text == nil || element.element_text.length == 0
      return "[no text]"
    end
    
    text = strip_tags(element.element_text)
    if text.length < 30
      return text
    else
      return text[0..29] + "..."
    end
  end
  
  def element_pic_thumbnail(element)
    illustrations = element.exhibit_illustrations
    if illustrations.length > 0
      element_pic_thumbnail_illustration(illustrations[0])
    else
      "<img src='#{get_image_url(nil)}' height='16px' />"
    end
  end
  
  def get_image_url(url)
    if url == nil || url.length == 0
      return DEFAULT_THUMBNAIL_IMAGE_PATH # '../images/lg-harrington.gif'
    end
    return url
  end
  
  def element_pic_thumbnail_illustration(illustration)
    if illustration.illustration_type == ExhibitIllustration.get_illustration_type_image()
      "<img src='#{get_image_url(illustration.image_url)}' height='16px' />"
    elsif illustration.illustration_type == ExhibitIllustration.get_illustration_type_nines_obj()
      thumb = CachedResource.get_thumbnail_from_uri(illustration.nines_object_uri)
      "<img src='#{get_image_url(thumb)}' height='16px' />"
    elsif illustration.illustration_type == ExhibitIllustration.get_illustration_type_text()
      "..."
    end
  end

  def tree_node( page_num, item_id_prefix, class_name, toggle_function, exhibit_id, initial_state = :closed )
    display_none = 'style="display:none"'
    label = "<div class='outline_right_controls''>"
    label << link_to_function(up_char(), "doAjaxLinkOnPage('move_page_up', #{exhibit_id}, #{page_num} );", { :title => 'Move Page Up' })
    label << link_to_function(down_char(), "doAjaxLinkOnPage('move_page_down', #{exhibit_id}, #{page_num} );", { :title => 'Move Page Down' })
    label << '&nbsp;<span class="close_link">'
    label << link_to_function(del_char(), "doAjaxLinkOnPage('delete_page', #{exhibit_id}, #{page_num} );", { :title => 'Delete Page' })
    label << '</span>'
    label << "</div>"
    label << "<span id=\"#{item_id_prefix}_p#{page_num}_closed\" #{initial_state == :open ? display_none : ''} >"
    label << link_to_function(closed_char(),"#{toggle_function}('#{item_id_prefix}_p#{page_num}')")
    label << "</span>"
    label << "<span id=\"#{item_id_prefix}_p#{page_num}_opened\" #{initial_state == :closed ? display_none : ''} >"
    label << link_to_function(opened_char(), "#{toggle_function}('#{item_id_prefix}_p#{page_num}')")
    label << "</span>"
    label << "<span class='#{class_name}'>" + "Page " + page_num + "</span>"
  end  
end
