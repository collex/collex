class ExhibitSection < ActiveRecord::Base
  belongs_to :exhibit_page
  acts_as_list :scope => :exhibit_page
  
  has_many :exhibit_elements, :order => :position
end
