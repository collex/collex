class AddImageToExhibitIllustration < ActiveRecord::Migration
	def self.up
		change_table :exhibit_illustrations do |t|
			t.has_attached_file :upload
		end
	end

	def self.down
		drop_attached_file :exhibit_illustrations, :upload
	end
end
