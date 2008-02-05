class CachedDocument < ActiveRecord::Base
   validates_uniqueness_of :uri
   
   has_and_belongs_to_many :tags
   has_and_belongs_to_many :genres
   has_many :cached_agents   
   
   def self.cache_document( uri )

     # if this document already is cached, return it
     cached_document = CachedDocument.find_by_uri(uri)
     return cached_document unless cached_document.nil?
     
     # look the document up in solr
     solr_document = SolrResource.find_by_uri(uri) 
     return nil if solr_document.nil?
     
     # create a new cache document and populate it
     cached_document = CachedDocument.new
     cached_document.uri = solr_document.uri
     cached_document.title = solr_document.title
     cached_document.date_label = solr_document.date_labels.join('; ')
     cached_document.archive = solr_document.archive
     
     solr_document.properties.each do |property|
       agent_type = property.agent_type
       unless agent_type.nil?
        cached_agent = CachedAgent.new
        cached_agent.name = property.value
        cached_agent.agent_type = AgentType.find_or_create_by_name( agent_type )
        cached_document.cached_agents << cached_agent
       end
     end
     
     solr_document.genres.each do |genre|
       cached_document.genres << Genre.find_by_name( genre )
     end
     
     # save the cache document
     cached_document.save ? cached_document : nil
   end
  
end
