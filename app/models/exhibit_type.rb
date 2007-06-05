class ExhibitType < ActiveRecord::Base
  has_and_belongs_to_many :section_types, :join_table => "exhibit_section_types_exhibit_types", :class_name => "ExhibitSectionType"
end
