class EmailWaiting < ActiveRecord::Base
	def deliver
		logger.info("background task: #{Time.now}")
	end
end
