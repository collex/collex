class Cluster < ActiveRecord::Base
	has_many :exhibits
	has_many :discussion_threads
	belongs_to :group
  belongs_to :image#, :dependent=>:destroy
end
