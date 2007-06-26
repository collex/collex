class ExhibitedResource < ExhibitedItem
#   belongs_to :resource, :class_name => "SolrResource"
  
  def resource
    @resource ||= SolrResource.find_by_uri(self.uri)
  end
  
  # Make the resource's properties transparent
  def method_missing(method_id, *arguments)
    begin
      super
    rescue NoMethodError
      name = method_id.to_s
      self.resource.blank? ? nil : self.resource.__send__(name)
    end
  end
  
end
