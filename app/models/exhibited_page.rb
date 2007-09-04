class ExhibitedPage < ActiveRecord::Base
  has_many :exhibited_sections, :order => "position", :dependent => :destroy
  alias_method :sections, :exhibited_sections
  belongs_to :exhibit_page_type
  belongs_to :exhibit
  acts_as_list :scope => :exhibit
  
  def template
    self.exhibit_page_type.template
  end
  
  def sections_full?
    sections.count >= exhibit_page_type.max_sections
  end
  
  def uris
    self.sections.collect { |section| section.uris }.flatten
  end
  
  def title_message
    self.exhibit_page_type.title_message
  end
  
  def annotation_message
    self.exhibit_page_type.annotation_message
  end
  
end
