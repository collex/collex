class ExhibitElement < ActiveRecord::Base
  belongs_to :exhibit_page
  acts_as_list :scope => :exhibit_page
  
  has_many :exhibit_illustrations, :order => :position, :dependent=>:destroy
  
  def self.factory(page)
    return ExhibitElement.create(:exhibit_page_id => page, :border_type_enum => 0, :exhibit_element_layout_type => 'text', :element_text => "Enter Your Text Here")
  end
  
  def get_border_type
    case border_type_enum
      when 0: return "continue"
      when 1: return "start_border"
      when 2: return "start_no_border"
    end
  end
  
  def set_border_type(border_type)
    case border_type
      when "continue": self.border_type_enum = 0
      when "start_border": self.border_type_enum = 1
      when "start_no_border": self.border_type_enum = 2
    end
  end
  
  def change_layout(new_layout)
        self.exhibit_element_layout_type = new_layout
        save()
  end
  
  def copy_data_portion(src_element)
    # This copies everything except the control fields (that is, position, id, and the exhibit_page_id)
    self.exhibit_element_layout_type = src_element.exhibit_element_layout_type
    self.element_text = src_element.element_text
    self.border_type_enum = src_element.border_type_enum
    save()
    illustrations = src_element.exhibit_illustrations
    illustrations.each { |illustration|
      illustration.exhibit_element_id = id
      illustration.save()
    }
  end
end
