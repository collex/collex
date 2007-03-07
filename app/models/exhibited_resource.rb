class ExhibitedResource < ActiveRecord::Base
#   belongs_to :resource, :class_name => "SolrResource"
  belongs_to :exhibited_section
  acts_as_list :scope => :exhibited_section
  
  def resource
    @resource ||= SolrResource.find_by_uri(self.uri)
  end
  
end
