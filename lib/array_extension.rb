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

class Array
  # This is to deal with Solr response pieces more easily, which come back as [key,value,key,value] arrays.
  def to_hash
    h = {}
    0.upto(size / 2 - 1) do |i|
      n = i * 2
      h[self[n]] = self[n+1]
    end
    
    h
  end
end
