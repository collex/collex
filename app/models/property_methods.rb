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

module PropertyMethods
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
    
  def date_label_or_date
    self.date_label.blank? ? self.date : self.date_label
  end  
  
  def site
    self.archive.blank? ? nil : Site.find_by_code(self.archive)
  end
  
  # return an array of the agents with roles, stripping out "role_" from the prop.name.
  # It's fine to use SolrProperty with both SolrResources and ExhibitedResources, b/c they are for display only
  def roles_with_agents
    @roles_with_agents ||= properties.select {|prop| !prop.agent_type.nil? }.collect { |p| SolrProperty.new(:name => p.agent_type, :value => p.value) }
  end
  
  def agents
    roles_with_agents.collect {|prop| prop.value }
  end
  
  def agent
    agents.empty? ? nil : agents[0]
  end
  
end