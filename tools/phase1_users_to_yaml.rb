#!/usr/bin/ruby
require 'optparse'

OPTIONS = {
  :environment => "development",
}

ARGV.options do |opts|
  script_name = File.basename($0)
  opts.banner = "Usage: ruby #{script_name} [options]"

  opts.separator ""

  opts.on("-e", "--environment=name", String,
          "Specifies the environment to run this server under (test/development/production).",
          "Default: development") { |OPTIONS[:environment]| }
          
  opts.separator ""

  opts.on("-h", "--help",
          "Show this help message.") { puts opts; exit }

  opts.parse!
end
   

ENV["RAILS_ENV"] = OPTIONS[:environment]

require File.dirname(__FILE__) + '/../config/environment'

logger = Logger.new(STDERR)
logger.level = Logger::DEBUG

kowari = Kowari.new
model = Kowari.model("collex")

query = "select $username $email $fullname $pwhash from <rmi://nines.org/server1#user> where $subject <http://www.patacriticism.org/collex/schema#Username> $username and $subject <http://www.patacriticism.org/collex/schema#Email> $email and $subject <http://www.w3.org/2000/01/rdf-schema#label> $fullname and $subject <http://www.patacriticism.org/collex/schema#PasswordHash> $pwhash;"
results = kowari.query(query)

users = []
results.each do |item|
  users << {:username => item[:username], :fullname => item[:fullname], :email => item[:email], :pwhash => item[:pwhash]}
end

puts users.to_yaml
