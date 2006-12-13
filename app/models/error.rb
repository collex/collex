class Error < ActiveRecord::Base
	def self.list_all_errors
		find(:all)
	end
end
