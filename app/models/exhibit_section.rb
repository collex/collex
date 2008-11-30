class ExhibitSection < ActiveRecord::Base
  belongs_to :exhibit_page
  acts_as_list :scope => :exhibit_page
  
  has_many :exhibit_elements, :order => :position, :dependent=>:destroy
  
  
  def move_element_up(element_pos)
    if element_pos > 1
      exhibit_elements[element_pos-1].move_higher()
    else
      # That is the first element. Find the previous section and move it there.
      sections = ExhibitPage.find(exhibit_page_id).exhibit_sections
      if position > 1
        move_element_to_different_section(element_pos, sections[position-2], sections[position-2].exhibit_elements.length+1)
      else
        #That is the first section on this page. Move to previous page
        exhibit_id = ExhibitPage.find(exhibit_page_id).exhibit_id
        page_num = ExhibitPage.find(exhibit_page_id).position
        pages = Exhibit.find(exhibit_id).exhibit_pages
        if (page_num > 1) && (pages[page_num-2].exhibit_sections.length > 0)
          # There is another page, so add the element to that.
          dst_sections = pages[page_num-2].exhibit_sections
          move_element_to_different_section(element_pos, dst_sections[dst_sections.length-1], dst_sections[dst_sections.length-1].exhibit_elements.length+1)
        end
      end
    end
  end
  
  def move_element_down(element_pos)
    if element_pos < exhibit_elements.length 
      exhibit_elements[element_pos-1].move_lower()
    else
      # That is the last element. Find the next section and move it there.
      sections = ExhibitPage.find(exhibit_page_id).exhibit_sections
      if position < sections.length
        move_element_to_different_section(element_pos, sections[position], 1)
      else
        # That is the last section. Find the first section on the next page.
        exhibit_id = ExhibitPage.find(exhibit_page_id).exhibit_id
        page_num = ExhibitPage.find(exhibit_page_id).position
        pages = Exhibit.find(exhibit_id).exhibit_pages
        if (page_num < pages.length) && (pages[page_num].exhibit_sections.length > 0)
          # There is another page, so add the element to that.
          move_element_to_different_section(element_pos, pages[page_num].exhibit_sections[0], 1)
        end
      end
    end
  end
  
  def move_element_to_different_section(element_pos, dst_section, dst_position)
    # insert an element, then copy the current element onto it.
    new_element = dst_section.insert_element(dst_position)
    new_element.copy_data_portion(exhibit_elements[element_pos-1])
    delete_element(element_pos)
  end
  
  def insert_element(element_pos)
    new_element = ExhibitElement.create(:exhibit_section_id => id, :exhibit_element_layout_type => 'text', :element_text => "Enter Your Text Here")
    new_element.insert_at(element_pos)
    return new_element
  end
  
  def delete_element(element_pos)
    exhibit_elements[element_pos-1].remove_from_list()
    exhibit_elements[element_pos-1].destroy
    return delete_if_empty
  end
  
  def delete_if_empty
    if exhibit_elements.length > 0
      return true
    else
      remove_from_list()
      destroy()
      return false
    end
  end
end
