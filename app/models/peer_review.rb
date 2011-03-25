class PeerReview < ActiveRecord::Base
	belongs_to :image_full #, :dependent=>:destroy

	def self.get_list()
		badges = PeerReview.all
		list = []
		badges.each {|badge|
			list.push({ :value => badge.id, :text => "/#{ImageFull.find(badge.image_full_id).photo.url}" }) if badge.image_full_id
		}
		return list
	end

	def self.get_badge(id)
		return "" if id == nil || id == 0
		badge = PeerReview.find(id)
		return "" if !badge.image_full_id
		return "/#{badge.image_full.photo.url}"
	end
end
