##########################################################################
# Copyright 2008 Applied Research in Patacriticism and the University of Virginia
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

# Models a User-contributed (non-Solr) Resource for an +Exhibit+. It also uses +ExhibitedProperty+ to
# store the properties of the resource.
class ExhibitedUserResource < ExhibitedItem
  has_many :exhibited_properties, :foreign_key => "exhibited_resource_id", :dependent => :destroy
  alias_method :properties, :exhibited_properties
  include PropertyMethods
  
  # Since a new object must be created before the associated properties, we only validate on update
  validate :presence_of_title, :presence_of_role, :presence_of_publisher, :presence_of_date_label
  
  def presence_of_title
    errors.add_to_base("You must include a title") unless exhibited_properties.detect{|ep| ep.name == 'title' && !ep.value.blank?}
  end
  
  def presence_of_role
    errors.add_to_base("You must include at least one author, editor or translator") unless exhibited_properties.detect{|ep| (ep.name == 'role_AUT' || ep.name == 'role_EDT' || ep.name == 'role_TRL') && !ep.value.blank?}
  end

  def presence_of_publisher
    errors.add_to_base("You must include a publisher") unless exhibited_properties.detect{|ep| ep.name == 'role_PBL' && !ep.value.blank?}
  end  
  
  def presence_of_date_label
    errors.add_to_base("You must include a date") unless exhibited_properties.detect{|ep| ep.name == 'date_label' && !ep.value.blank?}
  end
  
end
