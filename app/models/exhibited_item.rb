class ExhibitedItem < ActiveRecord::Base
  belongs_to :exhibited_section
  alias_method :section, :exhibited_section
  acts_as_list :scope => :exhibited_section
end
