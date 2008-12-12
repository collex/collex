class ExhibitSection < ActiveRecord::Base
end

class MoveExhibitSectionDataToElement < ActiveRecord::Migration
  def self.up
    # Add a default border value .
    # Find what page the elements are on by looking at their section .
    # Renumber the position .
    page_position = {}
    elements = ExhibitElement.find(:all)
    for element in elements
      element.border_type_enum = 0
      section = ExhibitSection.find(element.exhibit_section_id)
      element.exhibit_page_id = section.exhibit_page_id

      pos = page_position[section.exhibit_page_id]
      pos = 0 unless pos
      element.position = pos + 1
      page_position[section.exhibit_page_id] = element.position
      element.save
    end
  end

  def self.down
  end
end
