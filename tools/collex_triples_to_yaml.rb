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

select_clause = "select $subject $predicate $object from #{model} where $subject $predicate $object"
query = "select count(#{select_clause}) from #{model} where $s $p $o;"
results = kowari.query(query)
total = results[0][:k0].to_i
logger.info "#{total} total triples"

items_per_query = 200
num_queries = total.quo(items_per_query).ceil

triples = []
for i in 1..num_queries
   offset = (i - 1) * items_per_query
   logger.info "Querying at offset #{offset}:"
   query = "#{select_clause} order by $subject limit #{items_per_query} offset #{offset};"
   results = kowari.query(query)
   
   results.each do |item|
      subject = item[:subject]
      predicate = item[:predicate]
      object = item[:object]
      
      triples << {:subject => subject, :predicate => predicate, :object => object}
   end
end

puts triples.to_yaml
