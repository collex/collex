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

class ExhibitedPage < ActiveRecord::Base
  has_many :exhibited_sections, :order => "position", :dependent => :destroy
  alias_method :sections, :exhibited_sections
  belongs_to :exhibit_page_type
  belongs_to :exhibit
  acts_as_list :scope => :exhibit
  
  def template
    self.exhibit_page_type.template
  end
  
  def sections_full?
    sections.count >= exhibit_page_type.max_sections
  end
  
  def uris
    self.sections.collect { |section| section.uris }.flatten
  end
  
  def title_message
    self.exhibit_page_type.title_message
  end
  
  def annotation_message
    self.exhibit_page_type.annotation_message
  end
  
end
