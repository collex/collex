##########################################################################
# Copyright 2007 Applied Research in Patacriticism and the University of Virginia
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################

require 'net/http'
require "erb"
include ERB::Util
require 'solr'

class CollexEngine
  def initialize(params={})
    @num_docs = -1
    
    @solr = Solr::Connection.new(SOLR_URL)
    @params = params
  end
  
  def connection
    @solr
  end
  
  def num_docs	# called for each entry point to get the number for the footer.
    if @num_docs == -1
      request = Solr::Request::Standard.new(:query=>"*:*", :rows=>0)
      response = @solr.send(request)
      
      @num_docs = response.total_hits
    end
    
    @num_docs
  end
  
#  def all_facets
#    # TODO!!!
#    # this is only used from the stats controller.  it needs to be ported to using Solr's Standard request, instead of the
#    # now removed FacetRequest
#    @solr.send(FacetRequest.new).all_facets
#  end
  
  def facet(facet, constraints, prefix=nil)	# called for autocomplete
    query, filter_queries = solrize_constraints(constraints)
    req = Solr::Request::Standard.new(
            :start => 0, :rows => 0,
            :query => query, :filter_queries => filter_queries,
            :facets => {:fields => [facet], :mincount => 1, :missing => (prefix ? false : true), :limit => -1, :prefix => prefix})
    
    response = @solr.send(req)
    facets_to_hash(response.data['facet_counts']['facet_fields'])[facet]
  end
  
  def agent_suggest(constraints, prefix)	# useful for auto complete on author, etc. fields.
    query, filter_queries = solrize_constraints(constraints)
    
    # case insensitive, replace commas, semicolons, and periods with spaces
    raw_query_string = prefix.downcase.sub(/[,;.]/," ")

    # each word in the query is a seperate name 
    names = raw_query_string.split(" ") 
            
    req = Solr::Request::Standard.new(
            :start => 0, :rows => 0,
            :query => "#{query} AND (#{name_query_string(names)})", :filter_queries => filter_queries,
            :facets => {:fields => ["role_ART", "role_AUT", "role_EDT", "role_PBL", "role_TRL"], :mincount => 1, :limit => -1})
    
    response = @solr.send(req)
    facets = facets_to_hash(response.data['facet_counts']['facet_fields'])
    agents = {}  
    hits = []
    facets.each do |role_with_prefix, role_data|
      role = role_with_prefix[-3,3]
      role_data.each do |name,freq|  
        names.each_index do |i|
          
         if name.downcase.starts_with?(names[i])
           # count this as a match 
           role_counts = agents[name] ||= {}
           role_counts[role] ||= 0
           role_counts[role] = role_counts[role] + freq             
         end
        end        
      end
    end
              
    retval = []
    agents.each do |name, roles|
      retval << {:name => name, :roles => roles, :total => roles.values.inject(0) {|total,val| total + val}}
    end
    retval.sort {|a,b| b[:total] <=> a[:total]}
  end
  
  def search(constraints, start, max, sort_by)	# called when the user requests a search.
    query, filter_queries = solrize_constraints(constraints)

    # TODO: switch to DisMax
		sort_param = sort_by ? [ { sort_by.to_sym => :ascending } ] : nil
    req = Solr::Request::Standard.new(:start => start, :rows => max, :sort => sort_param,
                                      :query => query, :filter_queries => filter_queries,
                                      :field_list => @params[:field_list],
                                      :facets => {:fields => @params[:facet_fields], :mincount => 1, :missing => true, :limit => -1},
                                      :highlighting => {:field_list => ['text'], :fragment_size => 600})
  
    results = {}
    results["total_documents"] = num_docs # TODO: pull from the response (but have to add it first)
  
    response = @solr.send(req)
  
    results["total_hits"] = response.total_hits
    results["hits"] = response.hits
  
    # Reformat the facets into what the UI wants, so as to leave that code as-is for now
    results["facets"] = facets_to_hash(response.data['facet_counts']['facet_fields'])
    results["highlighting"] = response.data['highlighting']
  
    results
  end
  
#  def indexed?(uri)
#    query = "uri:#{Solr::Util.query_parser_escape(uri)}"
#    req = Solr::Request::Standard.new(:start => 0, :rows => 1, :query => query)
#    response = @solr.send(req)
#    response.hits[0] != nil
#  end
  
  def object_detail(objid, username=nil)	#called by SolrResource.find_by_uri
    query = "uri:#{Solr::Util.query_parser_escape(objid)}"
    # TODO: generalize the field list here
    field_list = ["archive","date_label","genre","role_ART", "role_AUT", "role_EDT", "role_PBL", "role_TRL","source","thumbnail","image","title","alternative","uri","url", "username"]
    # TODO: tag is not currently stored, but to store it requires some strange contortions in #add_collectables currently
    # however, to get tags, you could facet on the tag field
    # field_list << 'tag' 
    if username
      field_list << "#{username}_tag"
      field_list << "#{username}_annotation"
    end
    req = Solr::Request::Standard.new(
             :start => 0, :rows => 1,
             :query => query, :field_list => field_list,
             :mlt => {:count => 3, :field_list => ["title", "genre", "agent", "year", "text","tag"], :min_term_freq => 1})
    
    response = @solr.send(req)
    
    document = response.hits[0]
    mlt = response.data['moreLikeThis'][objid]['docs'] rescue []
    collection_info = username ? {'users' => document['username'] || []} : nil  rescue nil
    
    [document, mlt, collection_info]
  end
  
  def objects_for_uris(uris, username=nil) #called when "collect" is pressed.
    #TODO allow paging through rows
    
    query = uris.collect {|uri| "uri:#{Solr::Util.query_parser_escape(uri)}"}.join(" OR ")
    # TODO: generalize the field list here
    field_list = ["archive","date_label","genre","role_ART", "role_AUT", "role_EDT", "role_PBL", "role_TRL","source","thumbnail","title","alternative","uri","url", "username"]
    if username
      field_list << "#{username}_tag"
      field_list << "#{username}_annotation"
    end
    req = Solr::Request::Standard.new(
             :start => 0, :rows => 500,
             :query => query, :field_list => field_list)
    
    response = @solr.send(req)
    response.hits
  end

  def objects_behind_urls(urls, username=nil)
    #TODO allow paging through rows
    query = urls.collect {|url| "url:#{Solr::Util.query_parser_escape(url)}"}.join(" OR ")
    # TODO: generalize the field list here
    field_list = ["archive","date_label","genre","role_ART", "role_AUT", "role_EDT", "role_PBL", "role_TRL","source","thumbnail","title","alternative","uri","url", "username"]
    if username
      field_list << "#{username}_tag"
      field_list << "#{username}_annotation"
    end
    req = Solr::Request::Standard.new(
             :start => 0, :rows => 500,
             :query => query, :field_list => field_list)
    
    response = @solr.send(req)
    response.hits
  end
  
  # Modifies or adds a document to Solr index. Currently only handles uri/tags/comments
  def add_collectables(username, collectables)
    collectables.each do |uri, info|
      tags = info[:tags]
      annotation = info[:annotation]
      
      req = Solr::Request::ModifyDocument.new(
          :uri => uri,
          :overwrite => {"#{username}_annotation" => annotation,
                         "#{username}_tag" => tags,
                        },
          :distinct => {:username => username})
      @solr.send(req)      
    end
  end

  def update_collectables(username, uri, tags, annotation)
    add_collectables(username, {uri => {:tags => tags, :annotation => annotation}})
  end

  def remove_collectables(username, uri)
    req = Solr::Request::ModifyDocument.new(
        :uri => uri,
        :overwrite => {"#{username}_annotation" => nil,
                       "#{username}_tag" => nil,
                      },
        :delete => {:username => username})
    @solr.send(req)      
  end
  
  def optimize
    @solr.optimize
  end
  
  def commit
    @solr.commit(:wait_searcher => false, :wait_flush => false)
  end
  
  def name_query_string( names )
    # search on each name in the query
    query_string = ""
    names.each_index { |i|
      last = (names.size-1 == i)
      and_string = last ? "" : " AND "
      # example: agent:gabriel* AND agent:dante* AND agent:rossetti*
      query_string << "agent:#{names[i]}*#{and_string}"
    }
    
    # return the accumulated query string and the names in it
    return query_string
  end

private
  # splits constraints into a full-text query (for relevancy ranking) and filter queries for constraining
  def solrize_constraints(constraints)
    queries = []
    filter_queries = []
    constraints.each do |constraint|
      if constraint.is_a?(ExpressionConstraint)
        queries << constraint.to_solr_expression
      else
        filter_queries << constraint.to_solr_expression
      end
    end
    queries << "*:*" if queries.empty?
    
    [queries.join(" AND "), filter_queries]
  end
  
  def facets_to_hash(facet_data)
    # TODO: change how <unspecified> is dealt with, so that it can link back to a -field:[* TO *] query.
    #       Leave nil as-is here, let the UI deal with rendering it as <unspecified>
    facets = {}
    facet_data.each do |facet,values|
      facets[facet] = {}
      Solr::Util.paired_array_each(values) do |key, value|
        # despite requesting mincount => 1, nil (aka "<unspecified>") items can be returned with zero count anyway
        facets[facet][key || "<unspecified>"] = value if value > 0 
      end
    end
    facets
  end
end
