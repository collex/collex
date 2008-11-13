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
      "[no text]"
    elsif element.element_text.length < 30
      element.element_text
    else
      element.element_text[0..29] + "..."
    end
  end
  
  def element_pic_thumbnail(element)
    illustrations = element.exhibit_illustrations
    if illustrations.length > 0
      "<img src='#{illustrations[0].image_url}' height='16px' />"
    else
      "<img src='../images/lg-harrington.gif' height='16px' />"
    end
  end
  
  def element_pic_thumbnail_illustration(illustration)
      "<img src='#{illustration.image_url}' height='16px' />"
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
