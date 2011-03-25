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

class FacetConstraint < Constraint
  def to_solr_expression
    if self.value == '<unspecified>'
      "#{inverted ? '' : '-'}#{fieldx}:[* TO *]"
    else
      # no need to quote the value here. In fact,
      # adding additional quotes can mess up the search
      # if the user already quoted it
      "#{operator}#{fieldx}:\"#{self.value}\""
    end
  end
      
  # used for creating fragment cache keys
  def to_s
    identifier = "#{fieldx}_#{value}".downcase.gsub(/\W/,'_')
    "#{operator}#{identifier}"
  end
end