#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "production"

require File.dirname(__FILE__) + "/../../config/application"
Rails.application.require_environment!

$running = true
Signal.trap("TERM") do 
  $running = false
end

loop_size = SESSION_CLEANER_INTERVAL_SECS / 5

DaemonActivity.started('session_cleaner')

while($running) do
	
	sql = "DELETE FROM sessions WHERE updated_at < DATE_SUB(NOW(), INTERVAL 1 DAY)" 
  	ActiveRecord::Base.connection.execute(sql) 
  	status = { :activity => true, :message => "Sessions older than 1 day deleted" }
	
	
	DaemonActivity.log_activity('session_cleaner', status)

	loop_size.times {
		sleep 5
		break if !$running
	}
end

DaemonActivity.ended('session_cleaner')
