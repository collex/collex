class Exhibit < ActiveRecord::Base
  has_many :exhibit_pages, :order => :position
  
  def insert_page(page_num)
    new_section = ExhibitPage.create(:exhibit_id => id)
    new_section.insert_at(page_num)
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
end
