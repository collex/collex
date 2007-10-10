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

class AddIllustratedEssayTypeAssociationsData < ActiveRecord::Migration

  class ExhibitType < ActiveRecord::Base
    has_and_belongs_to_many :exhibit_section_types
  end
  class ExhibitSectionType < ActiveRecord::Base
    has_and_belongs_to_many :exhibit_types
  end

  def self.up
    @et = ExhibitType.find(3)
    @ests = ExhibitSectionType.find([2,3,4])
    @et.exhibit_section_types << @ests
    @et.save!
  end
  def self.down
    @et = ExhibitType.find(3)
    @ests = @et.exhibit_section_types.find([2,3,4])
    @ests.each do |est|
      @et.exhibit_section_types.delete(est)      
    end
    @et.save!
  end
end
