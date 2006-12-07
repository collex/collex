class Contributor < ActiveRecord::Base
	validates_presence_of :archive_name, :email
	validates_uniqueness_of :archive_name
	
	def self.list_all_contributors
		find(:all, :order => "archive_name")
	end
end
