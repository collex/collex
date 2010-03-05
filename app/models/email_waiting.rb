class EmailWaiting < ActiveRecord::Base
	def self.periodic_update
		return { :activity => false }
	end
end
