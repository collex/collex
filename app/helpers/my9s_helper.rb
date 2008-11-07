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
      "<img src='#{illustrations[0].image_url}' height='20' />"
    else
      "<img src='../images/lg-harrington.gif' height='20' />"
    end
  end
  
  def element_pic_thumbnail_illustration(illustration)
      "<img src='#{illustration.image_url}' height='20' />"
  end
  
  def tree_node( item_name, item_id, item_id_prefix, class_name, toggle_function, initial_state = :closed )
    display_none = 'style="display:none"'
    label = "<span id=\"#{item_id_prefix}_#{item_id}_closed\" #{initial_state == :open ? display_none : ''} class='outline_toggle'>"
    label << link_to_function('&#x25BA;',"#{toggle_function}('#{item_id}')")
    label << "</span>"
    label << "<span id=\"#{item_id_prefix}_#{item_id}_opened\" #{initial_state == :closed ? display_none : ''} class='outline_toggle'>"
    label << link_to_function('&#x25BC;', "#{toggle_function}('#{item_id}')")
    label << "</span>"
    label << "<span class='#{class_name}'>" + item_name + "</span>"
  end  
end
