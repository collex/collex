class ResourceController < ApplicationController
  # post currently emulates the request sent to Solr, to allow the indexer to post here instead of to Solr
  def post
    solr = Solr.new
    
    data = request.env['RAW_POST_DATA']
    if data == "<commit/>"
      solr.commit
      render :text => "OK"
      return
    end
    
    if data == "<optimize/>"
      solr.optimize
      render :text => "OK"
      return
    end
    
    dom = REXML::Document.new request.env['RAW_POST_DATA']
    xml = REXML::Element.new('add')
    dom.elements.each("add/doc") do |doc|
      uri = nil
      properties = []
      text = ""
      text_url = nil
      doc.elements.each("field") do |field|
        name = field.attributes["name"]
        value = field.text
        
        next if name == "type"  # don't store "type" property, this is a Solr-only field
        next if name == "agent" # "agent" is duplicated from the role_XXX
        
        # TODO - handle text data separately - only write it to Solr
        
        case name
          when "uri"   # URI _is_ the Resource, not a property of it
            uri = value
          when "text"  # "text" is treated differently because we only store it in the DB if it is inlined text, not fetched from a URL
            text = value
          else
            properties << Property.new(:name=>name, :value=>value)
            if name == "text_url"
              text_url = value
            end
        end
      end
      
      if not text_url # if text was inlined in the RDF, we store it, otherwise we simply store the URL (above)
        properties << Property.new(:name=>"text", :value=>text)
      end
      
      resource = Resource.find_or_create_by_uri(uri)
      resource.properties.destroy_all
      resource.properties << properties
      
      # Save to the database
      resource.save!

      # Save to Solr
      solr_doc = REXML::Element.new('doc')
      solr_doc.add_element solr.field("uri", resource.uri)
      solr_doc.add_element solr.field("type", "A")
      solr_doc.add_element solr.field("text", text)
      resource.properties.each do |property|
        next if property.name == "text_url" # Solr doesn't use text_url, only text
        solr_doc.add_element(solr.field(property.name, property.value)) unless property.name == "text_url" # Solr doesn't use text_url
        if property.name =~ /^role_[A-Z]{3}$/  # TODO take care of this with a <copyField> on the Solr side instead
          solr_doc.add_element solr.field("agent", property.value) 
        end
      end
      xml.add_element solr_doc        
    end
    
    response = solr.post_to_solr(xml.to_s, :update)
    
    render :text => "OK"
  end
end
