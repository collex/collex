class CachedDocument < ActiveRecord::Base
   validates_uniqueness_of :uri
   
   has_and_belongs_to_many :tags
   has_and_belongs_to_many :genres
   has_many :cached_agents
   has_many :cached_dates   
   
    CLOUD_SQL = { 
      :archive => "select archive as name, count(archive) as freq from cached_documents as docs join interpretations as i on docs.uri=i.object_uri group by archive order by freq,name limit ?",
      :agent_facet => "select name, count(name) as freq from cached_agents as agents join cached_documents as docs on docs.id=agents.cached_document_id join interpretations as i on docs.uri=i.object_uri group by name order by freq,name limit ?", 
      :tag => "select name, count(name) as freq from tags join taggings on tags.id=taggings.tag_id join interpretations as i on taggings.interpretation_id=i.id group by name order by freq,name limit ?",
      :genre => "select name, count(name) as freq from genres join cached_documents_genres as docs_genres on genres.id=docs_genres.genre_id join cached_documents as docs on docs_genres.cached_document_id=docs.id join interpretations as i on docs.uri=i.object_uri group by name order by freq,name limit ?",     
      :username => "select username as name, count(username) as freq from users join interpretations as i on users.id=i.user_id group by username order by freq,name limit ?",
      :year => "select date as name, count(date) as freq from cached_dates as dates join cached_documents as docs on dates.cached_document_id=docs.id group by dates.date order by freq,name limit ?"
    }
    
    CLOUD_BY_USER_SQL = { 
      :archive => "select archive as name, count(archive) as freq from cached_documents as docs join interpretations as i on docs.uri=i.object_uri where user_id=? group by archive order by freq,name limit ?",
      :agent_facet => "select name, count(name) as freq from cached_agents as agents join cached_documents as docs on docs.id=agents.cached_document_id join interpretations as i on docs.uri=i.object_uri where user_id=? group by name order by freq,name limit ?", 
      :tag => "select name, count(name) as freq from tags join taggings on tags.id=taggings.tag_id join interpretations as i on taggings.interpretation_id=i.id where user_id=? group by name order by freq,name limit ?",
      :genre => "select name, count(name) as freq from genres join cached_documents_genres as docs_genres on genres.id=docs_genres.genre_id join cached_documents as docs on docs_genres.cached_document_id=docs.id join interpretations as i on docs.uri=i.object_uri where user_id=? group by name order by freq,name limit ?",
      :username => "select username as name, count(username) as freq from users join interpretations as i on users.id=i.user_id where users.id = ? group by username order by freq,name limit ?",
      :year => "select date as name, count(date) as freq from cached_dates as dates join cached_documents as docs on dates.cached_document_id=docs.id join interpretations as i on docs.uri=i.object_uri where user_id=? group by dates.date order by freq,name limit ?"      
    }
    
    LIST_SQL_SELECT = "select docs.* from cached_documents as docs"
    LIST_SQL_COUNT = "select count(*) as hits from cached_documents as docs"
    LIST_SQL_ORDER_AND_LIMIT = "order by title limit ?,?"
    
    LIST_BY_TAG_SQL = {
      :archive => "where archive=?",
      :agent_facet => "join cached_agents as agents on docs.id=agents.cached_document_id where agents.name = ?", 
      :tag => "join cached_documents_tags as doc_tags on docs.id=doc_tags.cached_document_id join tags on doc_tags.tag_id=tags.id where tags.name=?", 
      :genre => "join cached_documents_genres as doc_genres on docs.id=doc_genres.cached_document_id join genres on doc_genres.genre_id=genres.id where genres.name=?",
      :username => "join interpretations as i on docs.uri=i.object_uri join users on i.user_id=users.id where i.user_id.username=?",
      :year => "join cached_dates as dates on docs.id=dates.cached_document_id where dates.date = ?"
    }

    LIST_BY_USER_BY_TAG_SQL = {
      :archive => "join interpretations as i on docs.uri=i.object_uri where archive=? and i.user_id = ?",
      :agent_facet => "join interpretations as i on docs.uri=i.object_uri join cached_agents as agents on docs.id=agents.cached_document_id where agents.name = ? and i.user_id = ?", 
      :tag => "join interpretations as i on docs.uri=i.object_uri join cached_documents_tags as doc_tags on docs.id=doc_tags.cached_document_id join tags on doc_tags.tag_id=tags.id where tags.name=? and i.user_id = ?", 
      :genre => "join interpretations as i on docs.uri=i.object_uri join cached_documents_genres as doc_genres on docs.id=doc_genres.cached_document_id join genres on doc_genres.genre_id=genres.id where genres.name=? and i.user_id = ?",   
      :username => "join interpretations as i on docs.uri=i.object_uri join users on i.user_id=users.id where users.username=? and i.user_id = ?",
      :year => "join interpretations as i on docs.uri=i.object_uri join cached_dates as dates on docs.id=dates.cached_document_id where dates.date = ? and i.user_id = ?"
    }

    DOCUMENT_LIMIT = 1000

   # Returns a sorted array of [name,freq] pairs for the specified cloud type and optional user_id
   def self.cloud( type, user=nil, limit=nil )
     type = type.to_sym
     limit = limit.nil? ? DOCUMENT_LIMIT : limit.to_i
           
     if user.nil? 
       cloud_of_ar_objects = find_by_sql([ CLOUD_SQL[type], limit ]) 
     else
       cloud_of_ar_objects = find_by_sql([ CLOUD_BY_USER_SQL[type], user, limit ])
     end      
          
     # convert active record objects to [name,freq] pairs
     unless cloud_of_ar_objects.nil?  
       return cloud_of_ar_objects.map { |entry| [ entry.name, entry.freq.to_i ] }
     else
       return []
     end
   end
   
   # Returns a sorted array of CachedDocument objects associated with a given cloud tag and optionally restricts by user
   def self.list_from_cloud_tag( type, tag, user=nil, offset=0, limit=nil )
     type = type.to_sym
     offset = offset.to_i
     limit = limit.nil? ? DOCUMENT_LIMIT : limit.to_i

      if user.nil? 
        list = find_by_sql([ "#{LIST_SQL_SELECT} #{LIST_BY_TAG_SQL[type]} #{LIST_SQL_ORDER_AND_LIMIT}", tag, offset, limit ]) 
        count = find_by_sql([ "#{LIST_SQL_COUNT} #{LIST_BY_TAG_SQL[type]}", tag ]).first.hits.to_i
      else
        list = find_by_sql([ "#{LIST_SQL_SELECT} #{LIST_BY_USER_BY_TAG_SQL[type]} #{LIST_SQL_ORDER_AND_LIMIT}", tag, user, offset, limit ]) 
        count = find_by_sql([ "#{LIST_SQL_COUNT} #{LIST_BY_USER_BY_TAG_SQL[type]}", tag, user ]).first.hits.to_i
      end      
      
      return list, count
   end   
   
   # Looks up the specified document in the Solr index and creates a CachedDocument object. Returns the existing
   # cached document or the newly created one. Does not save the created object.
   def self.create_cache_document( uri )

     if uri.kind_of?(Array) 
       cached_docs = []
       uncached_docs = []
       
       # pull out the docs that have already been cached
       uri.each { |current_uri|
         cached_document = CachedDocument.find_by_uri(current_uri)
         if cached_document.nil?
           uncached_docs << current_uri
         else   
           cached_docs << cached_document
         end
       }
       
       # retrieve the remaining documents from solr and cache them
       unless uncached_docs.empty?       
        solr_documents = SolrResource.find_by_uri( uncached_docs )
        solr_documents.each { |solr_doc| cached_docs << cache_solr_resource( solr_doc ) }
       end
       
       return cached_docs       
     else       
       # if this document already is cached, return it
       cached_document = CachedDocument.find_by_uri(uri)
       return cached_document unless cached_document.nil?
       
       # look the document up in solr
       solr_document = SolrResource.find_by_uri(uri) 
       return nil if solr_document.nil?
       
       return cache_solr_resource( solr_document )
     end

   end
   
   
   def self.cache_solr_resource( solr_document )
     
     # create a new cache document and populate it
     cached_document = CachedDocument.new
     cached_document.uri = solr_document.uri
     cached_document.title = solr_document.title
     cached_document.archive = solr_document.archive

     solr_document.date_labels.each do |date_label|
       date = CachedDate.new
       date.date = date_label
       cached_document.cached_dates << date
     end
     
     solr_document.properties.each do |property|
       agent_type = property.agent_type
       unless agent_type.nil?
        cached_agent = CachedAgent.new
        cached_agent.name = property.value
        cached_agent.agent_type = AgentType.find_or_create_by_name( agent_type )
        cached_document.cached_agents << cached_agent
       end
     end
     
     solr_document.genres.each do |genre_name|
       genre = Genre.find_by_name( genre_name )
       unless genre.nil?
         cached_document.genres << genre
       else
         logger.error "Unable to cache genre: '#{genre_name}' for document: #{solr_document.uri}"
       end
     end

     cached_document
   end
   
   def date_label
     @date_label ||= cached_dates.map { |date| date.date }.join("; ")
   end
      
end
