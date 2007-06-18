class ExhibitPageType < ActiveRecord::Base
  belongs_to :exhibit_type
  has_many :section_types, :class_name => "ExhibitSectionType"
end
