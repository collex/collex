# encoding: UTF-8
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

class ExpressionConstraint < Constraint
	def clean_search_term(str)
		str = str.gsub(/[\(\):\}\{\^\]\[]/u, '')
		# solr complains if the first char is a wild card
		str = str.sub('*', '') if str[0] == '*'
		str = str.sub('?', '') if str[0] == '?'
    return str
  end

	def to_solr_expression
		term = clean_search_term(value)
		return "" if term.length == 0
		return "#{operator=='-' ? '-' : '+'}#{term}"
	end
  
  def to_s
     identifier = value.downcase.gsub(/\W/,'_')
    "#{operator}phrase_#{identifier}"
  end
end
