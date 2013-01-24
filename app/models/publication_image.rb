class PublicationImage < ActiveRecord::Base
  belongs_to :image_full #, :dependent=>:destroy

	def self.get_list()
		images = PublicationImage.all
		list = []
		images.each {|image|
			list.push({ :value => image.id, :text => "/#{image.image_full.photo.url}" }) if image.image_full
		}
		return list
	end

	def self.get_image(id)
		return ActionController::Base.new.view_context.image_path(LARGE_THUMBNAIL_IMAGE_PATH) if id == nil || id == 0
		image = PublicationImage.find(id)
		return "" if !image.image_full
		return "/#{image.image_full.photo.url}"
	end
end
