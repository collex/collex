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

# Models a Solr Resource for an +Exhibit+. After +create+, the resource's properties are copied
# into +ExhibitedProperty+s for permanent storage in the +Exhibit+.
class ExhibitedResource < ExhibitedItem
  has_many :exhibited_properties, :dependent => :destroy
  alias_method :properties, :exhibited_properties
  include PropertyMethods
  
  after_create :copy_solr_resource
  
  # The actual +SolrResource+ at this instances +uri+. If none exists, then
  # an empty +SolrResource+ is created.
  # TODO Perhaps this method should be made private as +ExhibitedProperty+s should be
  # accessed, rather than properties on the +SolrResource+. 
  def resource
    @resource ||= SolrResource.find_by_uri(self.uri) || SolrResource.new
  end
  alias_method :solr_resource, :resource
  
  private
    #TODO filter out tags and annotations and usernames 
    def copy_solr_resource
      resource.properties.each do |prop|
        properties << ExhibitedProperty.new(:name => prop.name, :value => prop.value)
      end
    end
  
end
