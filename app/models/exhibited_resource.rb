class ExhibitedResource < ExhibitedItem
#   belongs_to :resource, :class_name => "SolrResource"
  
  def resource
    @resource ||= SolrResource.find_by_uri(self.uri) || SolrResource.new
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
  
  def date_label_or_date
    self.date_label.blank? ? self.date : self.date_label
  end
  
end
