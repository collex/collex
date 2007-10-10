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

class Tag < ActiveRecord::Base
  has_many :taggings, :dependent => :destroy
  has_many :interpretations, :through => :taggings

  validates_uniqueness_of :name

  class << self
    # Parses space separated tag list and returns tags for them.
    #
    #   Tag.parse_to_tags('a b c')
    #   # => [Tag, Tag, Tag]
    def parse_to_tags(list)
      find_or_create(parse(list))
    end
    
    # Parses a space separated list of tags into tag names
    #
    #   Tag.parse('a b c')
    #   # => ['a', 'b', 'c']
    def parse(string)
      if string.count('"') % 2 > 0
        string[string.rindex('"')] = ''
      end
      
      tags = []
      buffer = ""
      in_quotes = false
      string.downcase.each_char do |c|
        if in_quotes
          if c == '"'
            in_quotes = false
            tags << buffer unless buffer.empty?
            buffer = ""
          else
            buffer << c
          end
        else
          case c
            when '"'
              in_quotes = true
            when ' ', ','
              tags << buffer unless buffer.empty?
              buffer = ""
            else
              buffer << c
          end
        end
        
      end
      tags << buffer unless buffer.empty?

      tags.map {|tag| tag.gsub(/[^\w\"\,\-\s]/,'').gsub(/[^\w]/,'-')}.uniq
    end
    
    # Returns Tags from an array of tag names
    # 
    #   Tag.find_or_create(['a', 'b', 'c'])
    #   # => [Tag, Tag, Tag]
    def find_or_create(tag_names)
      transaction do
        found_tags = []
        found_tags = find(:all, :conditions => ['name IN (?)', tag_names]) if not tag_names.empty?
        found_tags + (tag_names - found_tags.collect(&:name)).collect { |s| create!(:name => s) }
      end
    end
  end

  def ==(object)
    super || name == object.to_s
  end
  
  def to_s
    name
  end

  def to_param
    name
  end

end
