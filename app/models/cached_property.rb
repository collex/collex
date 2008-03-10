class CachedProperty < ActiveRecord::Base
  belongs_to :cached_resource
  def agent_type()
    self.name =~ /^role_/ ? self.name[-3,3] : nil      
  end
  
  def ==(other)
    return false if other.nil?
    self.name == other.name and self.value == other.value
  end
end
