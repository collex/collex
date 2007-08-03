class Interpretation < ActiveRecord::Base
  validates_uniqueness_of :object_uri, :scope => :user_id
  
  belongs_to :user
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
