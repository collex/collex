class ExhibitIllustration < ActiveRecord::Base
  belongs_to :exhibit_element
  acts_as_list :scope => :exhibit_element
end
