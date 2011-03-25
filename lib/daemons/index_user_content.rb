#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "production"

require File.dirname(__FILE__) + "/../../config/application"
Rails.application.require_environment!

$running = true
Signal.trap("TERM") do 
	$running = false
end

loop_size = USER_CONTENT_INTERVAL_SECS / 5

DaemonActivity.started('index_user_content')

while($running) do
	status = SearchUserContent.periodic_update()
	DaemonActivity.log_activity('index_user_content', status)
  
	loop_size.times {
		sleep 5
		break if !$running
	}
end

DaemonActivity.ended('index_user_content')
