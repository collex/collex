class ExhibitPage < ActiveRecord::Base
  belongs_to :exhibit
  acts_as_list :scope => :exhibit
  
  has_many :exhibit_sections, :order => :position
end
