class ExhibitSectionType < ActiveRecord::Base
  has_and_belongs_to_many :exhibit_types
end
