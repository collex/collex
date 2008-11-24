class ExhibitElement < ActiveRecord::Base
  belongs_to :exhibit_section
  acts_as_list :scope => :exhibit_section
  
  has_many :exhibit_illustrations, :order => :position, :dependent=>:destroy
  
  def change_layout(new_layout)
        exhibit_element_layout_type = new_layout
        save
  end
end
