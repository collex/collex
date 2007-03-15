class ExhibitedSection < ActiveRecord::Base
  has_many :exhibited_resources, :order => "position", :dependent => :destroy
#   has_many :resources, :class_name => "SolrResource", :through => :exhibited_resources
  belongs_to :exhibit_section_type
  belongs_to :exhibit
  acts_as_list
  
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
