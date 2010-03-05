#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "production"

require File.dirname(__FILE__) + "/../../config/environment"

$running = true
Signal.trap("TERM") do 
  $running = false
end

loop_size = MAILER_INTERVAL_SECS / 5

DaemonActivity.started('mailer')

while($running) do
	status = EmailWaiting.periodic_update()
	DaemonActivity.log_activity('mailer', status)

	loop_size.times {
		sleep 5
		break if !$running
	}
end

DaemonActivity.ended('mailer')
