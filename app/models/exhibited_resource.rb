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

class ExhibitedResource < ExhibitedItem
  has_many :exhibited_properties, :dependent => :destroy
  alias_method :properties, :exhibited_properties
  include PropertyMethods
  
  after_create :copy_solr_resource
  
  def resource
    @resource ||= SolrResource.find_by_uri(self.uri) || SolrResource.new
  end
  
  
  private
    #TODO filter out tags and annotations and usernames 
    def copy_solr_resource
      resource.properties.each do |prop|
        properties << ExhibitedProperty.new(:name => prop.name, :value => prop.value)
      end
    end
  
end
