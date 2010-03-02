class PublicationImage < ActiveRecord::Base
  belongs_to :image#, :dependent=>:destroy

	def self.get_list()
		images = PublicationImage.all
		list = []
		images.each {|image|
			list.push({ :value => image.id, :text => image.image.public_filename }) if image.image
		}
		return list
	end

	def self.get_image(id)
		return "" if id == nil || id == 0
		image = PublicationImage.find(id)
		return "" if !image.image
		return image.image.public_filename
	end
end
