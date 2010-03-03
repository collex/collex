#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "production"

require File.dirname(__FILE__) + "/../../config/environment"

$running = true
Signal.trap("TERM") do 
  $running = false
end

loop_size = MAILER_INTERVAL_SECS / 5

ActiveRecord::Base.logger.info "----- START mailer #{Time.now}.\n"

while($running) do
	ActiveRecord::Base.logger.info "Daemon mailer is still running at #{Time.now}.\n"

	loop_size.times {
		sleep 5
		break if !$running
	}
end

ActiveRecord::Base.logger.info "----- STOP mailer #{Time.now}.\n"
