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

#TODO-PER: I think this isn't used anymore
class SolrProperty #< SolrBaseModel
#  belongs_to :solr_resource
#
#  column :name,  :string
#  column :value, :string
#
#  def agent_type()
#    self.name =~ /^role_/ ? self.name[-3,3] : nil
#  end
#
#  def ==(other)
#    return false if other.nil?
#    self.name == other.name and self.value == other.value
#  end
  
end
