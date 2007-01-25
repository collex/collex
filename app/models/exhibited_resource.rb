class ExhibitedResource < ActiveRecord::Base
  belongs_to :resource
  belongs_to :section, :class_name => "ExhibitedSection", :foreign_key => "exhibited_section_id"
end
