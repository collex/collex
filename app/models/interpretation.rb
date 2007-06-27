class Interpretation < ActiveRecord::Base
  validates_uniqueness_of :object_uri, :scope => :user_id
  after_save :update_solr
  after_destroy :remove_from_solr
  
  belongs_to :user
  has_many :taggings, :dependent => :destroy
  has_many :tags, :through => :taggings
  
  attr_accessor :solr_commit_disabled
  
  def tag_list
    tags.map { |t| t.name }.join(" ")
  end
  
  def tag_list=(tag_string)
    Tagging.set_on(self, tag_string)
    taggings.reset
    tags.reset
  end
      
  def update_solr
    solr = CollexEngine.new
    solr.update(user.username, object_uri, tags.collect { |tag| tag.name }, annotation)
    puts "****** #{solr_commit_disabled}"
    solr.commit unless solr_commit_disabled
  end
  
  def remove_from_solr
    solr = CollexEngine.new
    solr.remove(user.username, object_uri)
    solr.commit unless solr_commit_disabled
  end
end
