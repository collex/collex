class Exhibit < ActiveRecord::Base
  belongs_to :user
  belongs_to :license
  belongs_to :exhibit_type
  has_many :sections, :class_name => "ExhibitedSection"
  
  def template
    self.exhibit_type.template
  end
  
end
