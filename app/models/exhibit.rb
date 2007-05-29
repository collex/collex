class Exhibit < ActiveRecord::Base
  belongs_to :user
  belongs_to :license
  belongs_to :exhibit_type
  has_many :exhibited_sections, :order => "position"
  
  validates_presence_of :title, :license_id, :exhibit_type_id, :user_id
  
  def template
    self.exhibit_type.template
  end
  
  def uris
    self.exhibited_sections.collect { |es| es.uris }.flatten
  end
  
  # Takes a User object or a user_id
  def owner?(user)
    user.is_a?(Integer) ? self.user_id == user : self.user_id == user.id rescue false
  end
  
  def share!
    self.shared  = true
  end
  
  # Will throw an error if +published+ is true
  def unshare!
    self.shared = false
  end
  
  # When the value is +true+, just pass through.
  # When the value is +false+, throw an error if the exhibit is published.
  def shared=(value)
    case value
    when true
      write_attribute(:shared, value)
    when false
      published? ? raise(Exception, ("Can not unshare a published exhibit.")) : write_attribute(:shared, value)
    end
  end
  
  # Will throw an error if is called when +shared+ is +false+.
  def publish!
    self.published = true
  end
  def unpublish!
    self.published = false
  end
  
  # Will throw an error if value is +true+ when +shared+ is +false+.
  def published=(value)
    publishable? ? write_attribute(:published, value) : raise(Exception, ("Can not publish an unshared exhibit. You must share it first."))
  end
    
# Permissions
  def publishable?
    shared?
  end
  
  def deletable?
    !published?
  end

  def viewable_by?(viewer)
    shared? or viewer == user or viewer.admin_role?
  end

  def updatable_by?(editor)
    editor == user or editor.admin_role?
  end

  def deletable_by?(deleter)
    deleter == user or deleter.admin_role?
  end

  def creatable_by?(creator)
    !creator.guest_role?
  end  
  
end
