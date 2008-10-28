class Exhibit < ActiveRecord::Base
  has_many :exhibit_pages, :order => :position
end
