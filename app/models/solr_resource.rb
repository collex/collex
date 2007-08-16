class SolrResource < SolrBaseModel
  column   :uri,        :string
  
  attr_reader :users, :properties, :mlt
      
  # Simplify access to properties by name.  Examples:
  # resource.title => returns value of first title property found
  # resource.titles => returns an array of property values with name "title"
  def method_missing(method_id, *arguments)
    begin
      super
    rescue NoMethodError
      name = method_id.to_s
      singular_name = name.singularize
      props = properties.select {|prop| prop.name == singular_name }
      if name == singular_name
        props.blank? ? "" : props[0].value
      else
        props.collect { |prop| prop.value }
      end
    end
  end
  
  # return an array of the agents with roles, stripping out "role_" from the prop.name
  def roles_with_agents
    @roles_with_agents ||= properties.select {|prop| prop.name =~ /^role_/}.collect { |p| SolrProperty.new(:name => p.name[-3,3], :value => p.value) }
  end
  
  def site
    self.archive.blank? ? nil : Site.find_by_code(self.archive)
  end
  
  def initialize(*args)
    @users = []
    @properties = []
    @mlt = []
    super
  end
  
  # Find item(s) by uri from the Solr index
  def self.find_by_uri(*args)
    valid_options = [:user, :start, :rows]
    raise ArgumentError, "Need at least one argument" if args.blank?
    options = args.last.respond_to?(:to_hash) ? args.pop.symbolize_keys : {}
    options = {:start => 0, :rows => 20}.merge(options)
    options[:user] = nil if options[:user].blank?
    
    raise ArgumentError, "Need a uri (object id) for the search." if args.size < 1
    uri = args[0]
    directive = uri.kind_of?(Array) ? :all : :first
    
    result = case directive
    when :first
      object, mlt, collection_info = solr.object_detail(uri, options[:user])
      resource = initialize_object_detail(object, mlt, collection_info)
    when :all
      solr.objects_for_uris(uri, options[:user]).collect { |item| initialize_object_detail(item) }
    end
    result
  end
  
  def self.initialize_object_detail(object, mlt=[], collection_info=nil)
    return nil if object.nil?
    resource = SolrResource.new(:uri => object["uri"])
    object.each do |name, value|
      next if name == "uri"
      if value.kind_of? Array
        value.each { |v| resource.properties << SolrProperty.new(:name => name, :value => v) }
      else
        resource.properties << SolrProperty.new(:name => name, :value => value)
      end
    end
    mlt.each { |item| resource.mlt << SolrResource.initialize_object_detail(item) }
    collection_info['users'].each { |user| resource.users << user } unless collection_info.nil?
    
    resource
  end
    
end
