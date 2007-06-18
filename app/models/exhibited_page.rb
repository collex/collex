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
  
end
