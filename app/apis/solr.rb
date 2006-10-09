require 'net/http'
require "erb"
include ERB::Util
include REXML

class Solr
  def initialize
    @url = URI.parse(SOLR_URL)
    
    @num_docs = -1
  end
  
  def num_docs
    if @num_docs == -1
      response = eval(post_to_solr("qt=numdocs&wt=ruby"))
      
      @num_docs = response['numdocs']
    end
    
    @num_docs
  end
  
  def all_facets
    post_data = "qt=facet&wt=ruby"

    raw_response = post_to_solr(post_data)
    response = eval(raw_response)
    response['facets']
  end
  
  def facet(facet, constraints, field=nil, prefix=nil, username=nil)
    # TODO clean up arguments.... facet parameter not really used in Solr when prefix/field specified
    post_data = "qt=facet&facet=#{facet}&wt=ruby"
    post_data << encode_constraints(constraints)

    if prefix and field 
      post_data << "&field=#{field}&prefix=#{prefix.downcase}"
    end
    
    if username
      post_data << "&username=#{username}"
    end
    
    raw_response = post_to_solr(post_data)
    match = /ParseException: (.*)/.match(raw_response)
    results = {}
    if not match
      response = eval(raw_response)
      results = response[facet]
    end
    
    results
  end
  
  def search(constraints, start, max)
    post_data = "qt=search&fl=archive,agent,date_label,genre,role_*,source,thumbnail,title,uri,url&start=#{start}&rows=#{max}&ff=genre&ff=archive&wt=ruby&hl=on&hl.fl=text&hl.fragsize=600"
    post_data << encode_constraints(constraints)
    
    results = {}
    
    raw_response = post_to_solr(post_data)
    results["total_documents"] = num_docs # TODO: pull from the response (but have to add it first)
    match = /ParseException: (.*)/.match(raw_response)
    if match
      # if there is an expression parse exception, we simply return to the caller as if no docuemnts were found
      #org.apache.lucene.queryParser.ParseException: Lexical error at line 1, column 2.  Encountered: <EOF> after : ""
      # match[1] is the parse exception

      # fill in some slots the caller will expect      
      results["facets"] = {}
      results["total_hits"] = 0
    else
      response = eval(raw_response)
      results["total_hits"] = response['response']['numFound']

      # Extract hits documents
      results["hits"] = response['response']['docs']

      # Extract facets
      results["facets"] = response['facets']

      results["highlighting"] = response["highlighting"]
    end
    
    results
  end
  
  def object_detail(objid, user)
    post_data = "field=uri&qt=object&value=#{url_encode(objid)}&fl=title,genre,year,date_label,archive,agent,uri,url,archive,thumbnail,source&wt=ruby"
    if user
      post_data << "&username=#{user}"
    end
    
    response = eval(post_to_solr(post_data))
    docs = response['response']['docs']
    
    document = nil
    mlt = nil
    collection_info = nil
    if docs[0]
      document = docs[0]
      key = document['uri']
      mlt = response['mlt'][key]['docs']
      collection_info = response['collectable'][key]
    end
    
    [document, mlt, collection_info]
  end
  
  def objects_behind_urls(urls, user)
    #TODO allow paging through rows
    #TODO add switch to avoid getting "more like this" in the solr response - it isn't needed in the case of the collector
    post_data = "field=url&qt=object&wt=ruby&fl=title,genre,year,date_label,archive,agent,uri,url,archive,thumbnail,source&rows=500"
    if user
      post_data << "&username=#{user}"
    end
    
    post_data << urls.map {|url| "&value=#{url_encode(url)}"}.join
    
    results = []
    
    response = eval(post_to_solr(post_data))

    response['response']['docs']
  end
  
  def add(username, collectables)
    xml = REXML::Element.new('add')
    date = DateTime.now.strftime("%Y%m%d")
    
    # Add statements linking user to added objects
    collectables.each do |uri, info|
      tags = info[:tags]
      annotation = info[:annotation]
      
      doc = REXML::Element.new('doc')
      doc.add_element field("uri", "#{uri}/#{username}")
      doc.add_element field("type", "C")
      doc.add_element field("date_updated", date)
      doc.add_element field("username", username)
      doc.add_element field("object_uri", uri)
      doc.add_element field("annotation", annotation)
      tags.each {|tag| doc.add_element field("tag", tag) }
      
      xml.add_element doc
    end
    
#<add>
#<doc>
#  <field name="id">F8V7067-APL-KIT</field>
#  <field name="inStock">false</field>
#</doc>
#</add>

    response = post_to_solr(xml.to_s, :update)
#    puts "RESPONSE = \n#{response}\n---------"
    
    # TODO remove these when the optimized index issue is resolved
    #commit
    #optimize
  end

  def update(username, uri, tags, annotation)
    add(username, {uri => {:tags => tags, :annotation => annotation}})
  end

  def remove(username, uri)
    # <delete><id>05991</id></delete>
    post_to_solr("<delete><id>#{uri}/#{username}</id></delete>", :update)
  end
  
  def optimize
    post_to_solr('<optimize waitFlush="false" waitSearcher="false"/>', :update)  # TODO - solve the issue with optimization required - shouldn't be necessary
  end
  
  def commit
    post_to_solr('<commit waitFlush="false" waitSearcher="false"/>', :update)  # TODO - solve the issue with optimization required - shouldn't be necessary
  end

  def post_to_solr(body, mode = :search)
    post = Net::HTTP::Post.new(mode == :search ? "/solr/select" : "/solr/update")
    post.body = body
    post.content_type = 'application/x-www-form-urlencoded'
    response = Net::HTTP.start(@url.host, @url.port) do |http|
      http.request(post)
    end
    return response.body
  end

  def field(name, value)
    field = REXML::Element.new("field")
    field.add_attribute("name", name)
    field.add_text(value)
    
    field
  end

  private
  def encode_constraints(constraints)
    output = "&constraint=#{url_encode('type:A')}"
    constraints.each do |constraint|
      encoded_constraint = ""
      if constraint.has_key?(:expression)
        encoded_constraint << "?:#{constraint[:expression]}"
      else
        encoded_constraint << "-" if constraint[:invert]
        encoded_constraint << "#{constraint[:field]}:#{constraint[:value]}"
      end
      
      output << "&constraint=#{url_encode(encoded_constraint)}"
    end
    
     output
  end
  
end
