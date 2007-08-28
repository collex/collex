class ExhibitedProperty < ActiveRecord::Base
  belongs_to :exhibited_resource
  
  def ==(other)
    return false if other.nil?
    self.name == other.name and self.value == other.value
  end
  
end
