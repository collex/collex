class ExhibitObject < ActiveRecord::Base
  belongs_to :exhibit
  
  def self.add(exhibit_id, uri)
    return self.create(:exhibit_id => exhibit_id, :uri => uri)
  end
end
