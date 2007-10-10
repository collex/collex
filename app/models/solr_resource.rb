##########################################################################
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################

class SolrResource < SolrBaseModel
  column :uri, :string
  attr_reader :users, :properties, :mlt
  include PropertyMethods
  
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
    directive = uri.kind_of?(Array) ? :all : :first   # TODO: passing an array is never used, so this can probably be removed
    
    result = case directive
    when :first
      object, mlt, collection_info = solr.object_detail(uri, options[:user])
      resource = initialize_object_detail(object, mlt, collection_info)
    # TODO: :all doesn't seem to be used and can probably be removed
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
