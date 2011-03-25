##########################################################################
# Copyright 2009 Applied Research in Patacriticism and the University of Virginia
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

class FullTextConstraint < ExpressionConstraint
  def to_solr_expression
    #"#{operator}has_full_text:[* TO *]"
#    "#{operator}?:has_full_text:true"
	b = operator == '-' ? 'false' : 'true'
    "has_full_text:#{b}"
  end

  def to_s
    #"#{operator}?:has_full_text:[* TO *]"
#    "#{operator}?:has_full_text:true"
	  b = operator == '-' ? 'false' : 'true'
	  "has_full_text:#{b}"
  end
end
