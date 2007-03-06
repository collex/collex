require 'net/http'
require "erb"
include ERB::Util
require 'solr'

class CollexEngine
  def initialize
    @num_docs = -1
    
    @solr = Solr::Connection.new(SOLR_URL)
  end
  
  def num_docs
    if @num_docs == -1
      request = Solr::Request::Standard.new(:query=>"type:A", :rows=>0)
      response = @solr.send(request)
      
      @num_docs = response.total_hits
    end
    
    @num_docs
  end
  
  def all_facets
    @solr.send(FacetRequest.new).facets
  end
  
  def facet(facet, constraints, field=nil, prefix=nil, username=nil)
    @solr.send(FacetRequest.new(:facet => facet, :constraints => constraints, :field => field, :prefix => prefix, :username => username)).facet(facet)
  end
  
  def search(constraints, start, max)
    req = SearchRequest.new(:constraints => constraints, :start => start, :rows => max)
    
    results = {}
    results["total_documents"] = num_docs # TODO: pull from the response (but have to add it first)
    
    response = @solr.send(req)
    
    results["total_hits"] = response.total_hits
    results["hits"] = response.docs
    results["facets"] = response.facets
    results["highlighting"] = response.highlighting
    
    results
    
  rescue
    # In case a bad expression was sent, return empty data so user sees no error and gets zero results
    results["facets"] = {}
    results["total_hits"] = 0
    results
  end
  
  def object_detail(objid, username)
    req = ObjectRequest.new(:field => 'uri', :value => objid, :username => username)
    response = @solr.send(req)
    
    document = response.doc
    mlt = nil
    collection_info = nil
    if document
      mlt = response.mlt
      collection_info = {'users' => response.users}
    end
    
    [document, mlt, collection_info]
  end
  
  def objects_for_uris(uris, username=nil)
    #TODO allow paging through rows
    #TODO add switch to avoid getting "more like this" in the solr response - it isn't needed in the case of the collector
    req = ObjectRequest.new(:field => 'uri', :value => uris, :username => username, :rows => 500)
    response = @solr.send(req)
    response.docs
  end

  def objects_behind_urls(urls, username=nil)
    #TODO allow paging through rows
    #TODO add switch to avoid getting "more like this" in the solr response - it isn't needed in the case of the collector
    req = ObjectRequest.new(:field => 'url', :value => urls, :username => username, :rows => 500)
    response = @solr.send(req)

    response.docs
  end
  
  def add(username, collectables)
    date = DateTime.now.strftime("%Y%m%d")
    
    # Add statements linking user to added objects
    docs = []
    collectables.each do |uri, info|
      tags = info[:tags]
      annotation = info[:annotation]
      
      doc = {:uri => "#{uri}/#{username}",
             :type => 'C',
             :date_updated => date,
             :username => username,
             :object_uri => uri,
             :annotation => annotation,
             :tag => tags
            }
             
      docs << doc
    end
    
    @solr.add(docs)
  end

  def update(username, uri, tags, annotation)
    add(username, {uri => {:tags => tags, :annotation => annotation}})
  end

  def remove(username, uri)
    @solr.delete("#{uri}/#{username}")
  end
  
  def optimize
    @solr.optimize
  end
  
  def commit
    @solr.commit
  end
end
