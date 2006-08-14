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

model_name = ARGV[0]
word = ARGV[1]

kowari = Kowari.new
model = Kowari.model(model_name)

query = "select $subject from #{model} where $subject  <http://purl.org/dc/elements/1.1/type> '#{word.downcase}';"
results = kowari.query(query)

subjects = []
results.each do |item|
  subjects << item[:subject]
end   

insert_query = "insert "
delete_query = "delete "
subjects.each do |subject|
  insert_query << "<#{subject}> <http://purl.org/dc/elements/1.1/type> '#{word.capitalize}' "
  delete_query << "<#{subject}> <http://purl.org/dc/elements/1.1/type> '#{word.downcase}' "
end
insert_query << " into #{model};"
delete_query << " from #{model};"

logger.info insert_query
logger.info delete_query

if subjects.size > 0
  logger.info "Updating batch of #{subjects.size} items"
  kowari.query(insert_query)
  kowari.query(delete_query)
end   
