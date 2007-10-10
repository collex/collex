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

class Tagging < ActiveRecord::Base
  belongs_to :interpretation
  belongs_to :tag

  class << self
    # Sets the tags on the interpretation.  Only adds new tags and deletes old tags.
    #
    #   Tagging.set_on @interpretation, 'foo, bar'
    def set_on(interpretation, tag_list)
      current_tags  = interpretation.tags
      new_tags      = Tag.parse_to_tags(tag_list)
      delete_from interpretation, (current_tags - new_tags)
      add_to      interpretation, new_tags
    end
  
    # Deletes tags from the interpretation
    #
    #   Tagging.delete_from @interpretation, [1, 2, 3]
    #   Tagging.delete_from @interpretation, [Tag, Tag, Tag]
    def delete_from(interpretation, tags)
      delete_all ['interpretation_id = ? and tag_id in (?)', interpretation.id, tags.collect { |t| t.is_a?(Tag) ? t.id : t }] if tags.any?
    end

    # Adds tags to the interpretation
    #
    #   Tagging.add_to @interpretation, [Tag, Tag, Tag]
    def add_to(interpretation, tags)
      self.transaction do
        tags.each do |tag|
          next if interpretation.tags.include? tag
          create! :interpretation => interpretation, :tag => tag
        end
      end unless tags.empty?
    end
  end
end