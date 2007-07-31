class ExhibitedItem < ActiveRecord::Base
  belongs_to :exhibited_section
  alias_method :section, :exhibited_section
  acts_as_list :scope => :exhibited_section
  
  attr_writer :title_message, :annotation_message
  def title_message
    @title_message || "(Insert Title)"
  end
  def annotation_message
    @annotation_message || "(Insert Annotation)"
  end

end
