#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "production"

require File.dirname(__FILE__) + "/../../config/environment"

$running = true
Signal.trap("TERM") do 
	$running = false
end

loop_size = USER_CONTENT_INTERVAL_SECS / 5

ActiveRecord::Base.logger.info "----- START index_user_content #{Time.now}.\n"

while($running) do
	status = SearchUserContent.periodic_update()
	ActiveRecord::Base.logger.info "Daemon index_user_content is still running at #{Time.now}. #{status}\n"
  
	loop_size.times {
		sleep 5
		break if !$running
	}
end

ActiveRecord::Base.logger.info "----- STOP index_user_content #{Time.now}.\n"
