class PeerReview < ActiveRecord::Base
  belongs_to :image#, :dependent=>:destroy

	def self.get_list()
		badges = PeerReview.all
		list = []
		badges.each {|badge|
			list.push({ :value => badge.id, :text => badge.image.public_filename }) if badge.image
		}
		return list
	end

	def self.get_badge(id)
		return "" if id == nil || id == 0
		badge = PeerReview.find(id)
		return "" if !badge.image
		return badge.image.public_filename
	end
end
