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

class CreateInterpretations < ActiveRecord::Migration
  # Interpretation model without Solr hooks, since we're importing from Solr
  class Interpretation < ActiveRecord::Base
    has_many :taggings, :dependent => :destroy
    has_many :tags, :through => :taggings

    def tag_list
      tags.map { |t| t.name }.join(" ")
    end

    def tag_list=(tag_string)
      Tagging.set_on(self, tag_string)
      taggings.reset
      tags.reset
    end

  end
  
  # Other models included as they seem necessary
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
      #   Tag.parse('a, b, c')
      #   # => ['a', 'b', 'c']
      def parse(list)
        list.downcase.split.map(&:strip).delete_if { |s| s.blank? }.uniq
      end

      # Returns Tags from an array of tag names
      # 
      #   Tag.find_or_create(['a', 'b', 'c'])
      #   # => [Tag, Tag, Tag]
      def find_or_create(tag_names)
        transaction do
          found_tags = find(:all, :conditions => ['name IN (?)', tag_names])
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
      
  def self.up
    create_table :interpretations, :force => false do |t|
      t.column :user_id, :integer
      t.column :object_uri, :string
      t.column :annotation, :text
      t.column :created_on, :datetime
      t.column :updated_on, :datetime
    end
    
    create_table :taggings, :force => false do |t|
      t.column :tag_id, :integer
      t.column :interpretation_id, :integer
      t.column :created_on, :datetime
    end
    
    create_table "tags", :force => false do |t|
      t.column :name,            :string, :null => false
      t.column :created_on,      :datetime
    end
    add_index "tags", ["name"], :name => "tags_name", :unique => true
        
# migrate the tags by querying Solr for type:C - http://localhost:8983/solr/select?wt=ruby&q=type:C
    # write "Importing interpretations from Solr..."
    # solr = CollexEngine.new
    # post_data = "wt=ruby&q=type:C&rows=10000" # hard-coded to 10000, but our production server has < 300 interpretations now
    # data = eval(solr.post_to_solr(post_data))
    # docs = data['response']['docs']
    # write "#{docs.size} interpretations."
    # docs.each do |doc|
    #   user = User.find_by_username(doc['username'])
    #   if user
    #     interpretation = Interpretation.new(:user_id => user.id)
    #     interpretation.annotation = doc['annotation']
    #     interpretation.object_uri = doc['object_uri']
    #     tags = Tag.find_or_create(doc['tag']) if doc['tag']
    #     Tagging.add_to interpretation, tags if tags
    #     interpretation.save
    #   else
    #     write "  WARNING: User #{doc['username']} not found."
    #   end
    # end
    # write "Done importing interpretations from Solr."
  end

  def self.down
    drop_table :interpretations
    drop_table :taggings
    drop_table :tags
  end
    
end
