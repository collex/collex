#!/usr/bin/env ruby
open('/Users/paulrosen/temp.log', 'a') { |f|
  f.puts "----- STARTING #{Time.now} -----\n"
}
#sleep 10
#Debugger::start_server("localhost", 7001)
#sleep 10

# You might want to change this
ENV["RAILS_ENV"] ||= "development"

puts "here: mailer.rb"
require File.dirname(__FILE__) + "/../../config/environment"
puts "here: 2 mailer.rb"

$running = true
Signal.trap("TERM") do 
  $running = false
end

while($running) do
  #puts "This daemon is still running at #{Time.now}.\n"
open('/Users/paulrosen/temp.log', 'a') { |f|
  f.puts "!! I'm still running at #{Time.now}.\n"
}
  sleep 10
end
