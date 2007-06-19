class ExhibitedSection < ActiveRecord::Base
  has_many :exhibited_resources, :order => "position", :dependent => :destroy
  belongs_to :exhibit_section_type
  belongs_to :exhibited_page
  alias_method :page, :exhibited_page
  acts_as_list :scope => :exhibited_page
  
  # Just show one section per page by default
#   set_page_size 1
  
  def template
    self.exhibit_section_type.template
  end
  
  def resources
    self.exhibited_resources.collect { |er| er.resource }
  end
  
  def uris
    self.exhibited_resources.collect { |er| er.uri }
  end
  
end
