class FeaturedObject < ActiveRecord::Base
  belongs_to :image#, :dependent=>:destroy
end
