class Exchange < ActiveRecord::Base
	def self.list_all_exchanges
		find(:all)
	end
end
