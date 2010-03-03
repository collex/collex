#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "production"

require File.dirname(__FILE__) + "/../../config/environment"

$running = true
Signal.trap("TERM") do 
  $running = false
end

ActiveRecord::Base.logger.info "----- START mailer #{Time.now}.\n"

while($running) do
	ActiveRecord::Base.logger.info "Daemon mailer is still running at #{Time.now}.\n"
	sleep MAILER_INTERVAL_SECS
end

ActiveRecord::Base.logger.info "----- STOP mailer #{Time.now}.\n"
