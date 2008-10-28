class ExhibitElement < ActiveRecord::Base
  belongs_to :exhibit_section
  acts_as_list :scope => :exhibit_section
  
  has_many :exhibit_illustrations, :order => :position
end
