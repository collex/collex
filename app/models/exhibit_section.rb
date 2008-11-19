class ExhibitSection < ActiveRecord::Base
  belongs_to :exhibit_page
  acts_as_list :scope => :exhibit_page
  
  has_many :exhibit_elements, :order => :position
  
  
  def move_element_up(element_pos)
    exhibit_elements[element_pos-1].move_higher()
  end
  
  def move_element_down(element_pos)
    exhibit_elements[element_pos-1].move_lower()
  end
  
  def insert_element(element_pos)
    new_element = ExhibitElement.create(:exhibit_section_id => id, :exhibit_element_layout_type => 'text', :element_text => "Enter Your Text Here")
    new_element.insert_at(element_pos)
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
