class ExhibitedSection < ActiveRecord::Base
  has_many :exhibited_resources #, :class_name => "ExhibitedResource"
  has_many :resources, :through => :exhibited_resources
  belongs_to :exhibit_section_type
  
  def template
    self.exhibit_section_type.template
  end
end
