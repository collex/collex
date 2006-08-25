class Interpretation < ActiveRecord::Base
  before_save :update_solr
  before_destroy :remove_from_solr
  
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
      
  def update_solr
    COLLEX_MANAGER.update(user.username, object_uri, tags.collect { |tag| tag.name }, annotation)
  end
  
  def remove_from_solr
    COLLEX_MANAGER.remove(user.username, object_uri)
  end
end
