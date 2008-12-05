class Exhibit < ActiveRecord::Base
  has_many :exhibit_pages, :order => :position, :dependent=>:destroy
  has_many :exhibit_objects, :dependent=>:destroy
  
  def self.factory(user_id)
    exhibit = Exhibit.create(:title =>'Untitled', :user_id => user_id)
    exhibit.insert_page(1)
    return exhibit
  end
  
  def insert_page(page_num)
    new_page = ExhibitPage.create(:exhibit_id => id)
    new_page.insert_at(page_num)
    new_page.insert_section(1)
  end
  
  def move_page_up(page_num)
    curr_page = exhibit_pages[page_num-1]
    curr_page.move_higher()
  end
  
  def move_page_down(page_num)
    curr_page = exhibit_pages[page_num-1]
    curr_page.move_lower()
  end
  
  def delete_page(page_num)
    curr_page = exhibit_pages[page_num-1]
    curr_page.remove_from_list()
    curr_page.destroy
  end
  
  def self.find_by_illustration_id(illustration_id)
    illustration = ExhibitIllustration.find(illustration_id)
    return self.find_by_element_id(illustration.exhibit_element_id)
  end
  
  def self.find_by_element_id(element_id)
    element = ExhibitElement.find(element_id)
    return self.find_by_section_id(element.exhibit_section_id)
  end
  
  def self.find_by_section_id(section_id)
    section = ExhibitSection.find(section_id)
    page = ExhibitPage.find(section.exhibit_page_id)
    return Exhibit.find(page.exhibit_id)
  end
end
