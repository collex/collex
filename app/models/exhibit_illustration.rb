class ExhibitIllustration < ActiveRecord::Base
  belongs_to :exhibit_element
  acts_as_list :scope => :exhibit_element
  
  def before_save
    if illustration_type == 'Internet Image'
      illustration_type = 0
    elsif illustration_type == 'Textual Illustration'
      illustration_type = 1
    elsif illustration_type == 'NINES Object'
      illustration_type = 2
    else
      illustration_type = -1
    end
  end
  
  def after_ﬁnd
    if illustration_type == 0
      illustration_type = 'Internet Image'
    elsif illustration_type == 1
      illustration_type = 'Textual Illustration'
    elsif illustration_type == 2
      illustration_type = 'NINES Object'
    else
      illustration_type = 'Unknown'
    end
  end
  
  def self.get_illustration_type_array
    return "['Internet Image', 'NINES Object', 'Textual Illustration' ]"
  end
  
  def self.get_illustration_type_image
    return 'Internet Image';
  end
  
  def self.get_illustration_type_text
    return 'Textual Illustration';
  end
  
  def self.factory(element_id, pos)
    illustration = ExhibitIllustration.create(:exhibit_element_id => element_id, :illustration_type => 'Internet Image', :illustration_text => "", :caption1 => "", :caption2 => "", :image_width => 100, :link => "" )
    illustration.insert_at(pos)
    return illustration
  end
end
