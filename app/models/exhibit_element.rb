class ExhibitElement < ActiveRecord::Base
  belongs_to :exhibit_section
  acts_as_list :scope => :exhibit_section
  
  has_many :exhibit_illustrations, :order => :position, :dependent=>:destroy
  
  def change_layout(new_layout)
        self.exhibit_element_layout_type = new_layout
        save
  end
  
  def copy_data_portion(src_element)
    # This copies everything except the control fields (that is, position, id, and the exhibit_section_id)
    self.exhibit_element_layout_type = src_element.exhibit_element_layout_type
    self.element_text = src_element.element_text
    save()
    illustrations = src_element.exhibit_illustrations
    illustrations.each { |illustration|
      illustration.exhibit_element_id = id
      illustration.save()
    }
  end
end
