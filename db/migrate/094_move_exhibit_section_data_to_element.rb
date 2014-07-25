class MoveExhibitSectionDataToElement < ActiveRecord::Migration
  class ExhibitSection < ActiveRecord::Base
  end

  def self.up
    # Add a default border value .
    # Find what page the elements are on by looking at their section .
    # Renumber the position .
    page_position = {}
    elements = ExhibitElement.all()
    for element in elements
      element.border_type_enum = 0
      if element.exhibit_section_id != nil  # If there were a mix of new and old style objects, then this might not have been used.
        section = ExhibitSection.find_by_id(element.exhibit_section_id)
        element.exhibit_page_id = section.exhibit_page_id
  
        pos = page_position[section.exhibit_page_id]
        pos = 0 unless pos
        element.position = pos + 1
        page_position[section.exhibit_page_id] = element.position
        element.save
      end
    end
  end

  def self.down
  end
end
