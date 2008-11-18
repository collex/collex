class ExhibitPage < ActiveRecord::Base
  belongs_to :exhibit
  acts_as_list :scope => :exhibit
  
  has_many :exhibit_sections, :order => :position

  def insert_border(section)
    section.has_border = 1
    section.save
  end

  def insert_section(pos)
    new_section = ExhibitSection.create(:has_border => true, :exhibit_page_id => id)
    new_section.insert_at(pos)
    new_section.insert_element(1)
  end

  def move_top_of_border_down(section)
    # insert a section above the current one, then add the first element in this section to that one.
    # Then remove that element from this one.
    # NOTE: If there is only one element in the section, this degenerates into just removing the border.
    if section.exhibit_elements.length == 1
      delete_border(section)
    elsif section.exhibit_elements.length > 0
      new_section = ExhibitSection.create(:has_border => false, :exhibit_page_id => section.exhibit_page_id)
      new_section.insert_at(section.position)
      
      element = section.exhibit_elements[0]
      element.remove_from_list()
      element.exhibit_section_id = new_section.id
      element.position = 1
      element.save
    end
  end

  def move_bottom_of_border_up(section)
    #insert a section below the current one, then add the last element in this section to that one.
    #NOTE: If there is only one element in the section, this degenerates into just deleting the border.
    if section.exhibit_elements.length == 1
      delete_border(section)
    elsif section.exhibit_elements.length > 0
      new_section = ExhibitSection.create(:has_border => false, :exhibit_page_id => section.exhibit_page_id)
      new_section.insert_at(section.position+1)
      
      element = section.exhibit_elements[section.exhibit_elements.length-1]
      element.remove_from_list()
      element.exhibit_section_id = new_section.id
      element.position = 1
      element.save
    end
  end

  def move_top_of_border_up(section)
    # find the element just above this one and switch it from its section to this one.
    # NOTE: if it is the only element in that section, then delete that section, too.
    # NOTE: if this is the first section on the page, then we do nothing.
    if section.position > 1
      loser_section = exhibit_sections[section.position-2]
      if loser_section.exhibit_elements.length > 0
        element = loser_section.exhibit_elements[loser_section.exhibit_elements.length-1]
        element.remove_from_list()
        element.exhibit_section_id = section.id
        element.insert_at(1)
        element.save()
      end
      
      if loser_section.exhibit_elements.length == 0
        # If there is now an empty section, delete it
        loser_section.remove_from_list()
        loser_section.destroy()
      end
    end
  end

  def move_bottom_of_border_down(section)
    # find the element just below this one and switch it from its section to this one.
    # NOTE: if it is the only element in that section, then delete that section, too.
    # NOTE: if this is the last section on the page, then we do nothing.
    if section.position < exhibit_sections.length
      loser_section = exhibit_sections[section.position]
      if loser_section.exhibit_elements.length > 0
        element = loser_section.exhibit_elements[0]
        element.remove_from_list()
        element.exhibit_section_id = section.id
        element.insert_at(section.exhibit_elements.length)
        element.save()
      end
      
      if loser_section.exhibit_elements.length == 0
        # If there is now an empty section, delete it
        loser_section.remove_from_list()
        loser_section.destroy()
      end
    end
  end

  def delete_border(section)
    section.has_border = 0
    section.save
  end

end
