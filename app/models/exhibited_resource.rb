class ExhibitedResource < ExhibitedItem
  has_many :exhibited_properties, :dependent => :destroy
  alias_method :properties, :exhibited_properties
  include PropertyMethods
  
  after_create :copy_solr_resource
  
  def resource
    @resource ||= SolrResource.find_by_uri(self.uri) || SolrResource.new
  end
  
  
  private
    #TODO filter out tags and annotations and usernames 
    def copy_solr_resource
      resource.properties.each do |prop|
        properties << ExhibitedProperty.new(:name => prop.name, :value => prop.value)
      end
    end
  
end
