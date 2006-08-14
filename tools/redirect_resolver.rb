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

def resolve_redirect(url, limit=10)
   fail 'http redirect too deep' if limit.zero?

   response = Net::HTTP.get_response(URI.parse(url))
   while response.kind_of?(Net::HTTPRedirection)   
     if response.kind_of?(Net::HTTPRedirection)
       url = response['location']
     end
     response = Net::HTTP.get_response(URI.parse(url))
   end

   url
end   

ENV["RAILS_ENV"] = OPTIONS[:environment]

require File.dirname(__FILE__) + '/../config/environment'

logger = Logger.new(STDERR)
logger.level = Logger::DEBUG

model_name = ARGV[0]
if ARGV[1]
  archive = ARGV[1]
end

kowari = Kowari.new
model = Kowari.model(model_name)

# query all seeAlso's from the model
select_clause = "select $id $url from #{model} where $id <http://www.w3.org/2000/01/rdf-schema#seeAlso> $url"
if archive
  select_clause = select_clause + " and $id <http://www.nines.org/schema#archive> '#{archive}'"
end
query = "select count(#{select_clause}) from #{model} where $s <http://www.w3.org/2000/01/rdf-schema#seeAlso> $o;"
results = kowari.query(query)
total = results[0][:k0].to_i
logger.info "#{total} urls to resolve."

items_per_query = 100
num_queries = total.quo(items_per_query).ceil

resolved_list = []
for i in 1..num_queries
   offset = (i - 1) * items_per_query
   logger.info "Querying at offset #{offset}:"
   query = "#{select_clause} order by $id limit #{items_per_query} offset #{offset};"
   results = kowari.query(query)

   results.each do |item|
      url = item[:url]
      id = item[:id]
      
      logger.info "Checking #{url}"
      resolved_url = url
      resolved_url = resolve_redirect(url)
      
      if resolved_url != url
        logger.info "  ...resolved #{url} to #{resolved_url}"
        resolved_list << {:id => id, :resolved_url => resolved_url }
      end
   end   
end

update_query = "insert "
resolved_list.each do |resolved_item|
  update_query << "<#{resolved_item[:id]}> <http://www.w3.org/2000/01/rdf-schema#seeAlso> <#{resolved_item[:resolved_url]}> "
end
update_query << " into #{model};"

if resolved_list.size > 0
  logger.info "Updating batch of #{resolved_list.size} items"
  kowari.query(update_query)
end   
