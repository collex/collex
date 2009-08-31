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

require File.dirname(__FILE__) + '/../test_helper'

class CollexEngineTest < ActiveSupport::TestCase

def test_name_query_string
  @solr = CollexEngine.new()
  
#  test_query = ["austen", "jane" ]
#  name_query = @solr.name_query_string( test_query )
#  assert_equal name_query, "agent:austen* AND agent:jane*"
#
#  test_query = ["gabriel","dante","rossetti"]
#  name_query = @solr.name_query_string( test_query )
#  assert_equal name_query, "agent:gabriel* AND agent:dante* AND agent:rossetti*"
end

end