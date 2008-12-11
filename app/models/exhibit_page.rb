class ExhibitPage < ActiveRecord::Base
  belongs_to :exhibit
  acts_as_list :scope => :exhibit
  
  has_many :exhibit_elements, :order => :position, :dependent=>:destroy

  def insert_border(section)
#    section.has_border = 1
#    section.save
  end

 
#  def insert_section(pos)
#    new_section = ExhibitSection.create(:has_border => true, :exhibit_page_id => id)
#    new_section.insert_at(pos)
#    new_section.insert_element(1)
#  end

  def move_top_of_border_down(section)
    # insert a section above the current one, then add the first element in this section to that one.
    # Then remove that element from this one.
    # NOTE: If there is only one element in the section, this degenerates into just removing the border.
#    if section.exhibit_elements.length == 1
#      delete_border(section)
#    elsif section.exhibit_elements.length > 0
#      new_section = ExhibitSection.create(:has_border => false, :exhibit_page_id => section.exhibit_page_id)
#      new_section.insert_at(section.position)
#      
#      element = section.exhibit_elements[0]
#      element.remove_from_list()
#      element.exhibit_section_id = new_section.id
#      element.position = 1
#      element.save
#      
#      section.delete_if_empty()
#    end
  end

  def move_bottom_of_border_up(section)
    #insert a section below the current one, then add the last element in this section to that one.
    #NOTE: If there is only one element in the section, this degenerates into just deleting the border.
#    if section.exhibit_elements.length == 1
#      delete_border(section)
#    elsif section.exhibit_elements.length > 0
#      new_section = ExhibitSection.create(:has_border => false, :exhibit_page_id => section.exhibit_page_id)
#      new_section.insert_at(section.position+1)
#      
#      element = section.exhibit_elements[section.exhibit_elements.length-1]
#      element.remove_from_list()
#      element.exhibit_section_id = new_section.id
#      element.position = 1
#      element.save
#
#      section.delete_if_empty()
#    end
  end

  def move_top_of_border_up(section)
    # find the element just above this one and switch it from its section to this one.
    # NOTE: if it is the only element in that section, then delete that section, too.
    # NOTE: if this is the first section on the page, then we do nothing.
#    if section.position > 1
#      loser_section = exhibit_sections[section.position-2]
#      if loser_section.exhibit_elements.length > 0
#        element = loser_section.exhibit_elements[loser_section.exhibit_elements.length-1]
#        element.remove_from_list()
#        element.exhibit_section_id = section.id
#        element.insert_at(1)
#        element.save()
#      end
#      
#      # If there is now an empty section, delete it
#      loser_section.delete_if_empty()
#    end
  end

  def move_bottom_of_border_down(section)
    # find the element just below this one and switch it from its section to this one.
    # NOTE: if it is the only element in that section, then delete that section, too.
    # NOTE: if this is the last section on the page, then we do nothing.
#    if section.position < exhibit_sections.length
#      loser_section = exhibit_sections[section.position]
#      if loser_section.exhibit_elements.length > 0
#        element = loser_section.exhibit_elements[0]
#        element.remove_from_list()
#        element.exhibit_section_id = section.id
#        element.insert_at(section.exhibit_elements.length)
#        element.save()
#      end
#      
#      # If there is now an empty section, delete it
#      loser_section.delete_if_empty()
#    end
  end

  def delete_border(section)
#    section.has_border = 0
#    section.save
  end

  def move_element_up(element_pos)
    if element_pos > 1
      exhibit_elements[element_pos-1].move_higher()
    else
      # That is the first element. Find the previous page and move it there.
      page_num = self.position
      if page_num > 1
        pages = Exhibit.find(self.exhibit_id).exhibit_pages
        move_element_to_different_page(element_pos, pages[page_num-2], pages[page_num-2].exhibit_elements.length+1)
      end
    end
  end
  
  def move_element_down(element_pos)
    if element_pos < exhibit_elements.length 
      exhibit_elements[element_pos-1].move_lower()
    else
      # That is the last element. Find the next page and move it there.
      exhibit_id = self.exhibit_id
      page_num = self.position
      pages = Exhibit.find(exhibit_id).exhibit_pages
      if page_num < pages.length
        # There is another page, so add the element to that.
        move_element_to_different_page(element_pos, pages[page_num], 1)
      end
    end
  end
  
  def move_element_to_different_page(element_pos, dst_page, dst_position)
    # insert an element, then copy the current element onto it.
    new_element = dst_page.insert_element(dst_position)
    new_element.copy_data_portion(exhibit_elements[element_pos-1])
    delete_element(element_pos)
  end
  
  def insert_element(element_pos)
    new_element = ExhibitElement.factory(id)
    new_element.insert_at(element_pos)
    return new_element
  end
  
  def delete_element(element_pos)
    exhibit_elements[element_pos-1].remove_from_list()
    exhibit_elements[element_pos-1].destroy
    return false
  end
end
