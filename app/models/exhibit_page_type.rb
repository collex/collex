class ExhibitPageType < ActiveRecord::Base
  belongs_to :exhibit_type
  has_many :exhibit_section_types
  alias_method :section_types, :exhibit_section_types
end
