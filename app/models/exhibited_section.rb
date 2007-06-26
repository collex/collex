class ExhibitedSection < ActiveRecord::Base
  # exhibited_texts and exhibited_resources are subclasses of exhibited_items
  has_many :exhibited_items, :order => "position", :dependent => :destroy
  alias_method :items, :exhibited_items
  
  has_many :exhibited_texts, :order => "position"
  alias_method :texts, :exhibited_texts
  has_many :exhibited_resources, :order => "position"
  
  belongs_to :exhibit_section_type
  belongs_to :exhibited_page
  alias_method :page, :exhibited_page
  acts_as_list :scope => :exhibited_page
  
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
