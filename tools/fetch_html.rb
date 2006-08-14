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

dir = ARGV[0]
model_name = ARGV[1]
if ARGV[2]
  archive = ARGV[2]
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
logger.info "#{total} pages to fetch."

items_per_query = 100
num_queries = total.quo(items_per_query).ceil

for i in 1..num_queries
   offset = (i - 1) * items_per_query
   logger.info "Querying at offset #{offset}:"
   query = "#{select_clause} order by $id limit #{items_per_query} offset #{offset};"
   results = kowari.query(query)

   results.each do |item|
      # fetch HTML pages
      url = item[:url]
      id = item[:id]
      url.sub!(/#.*$/,'') # remove anchor from URL so we only fetch one copy of a page (TODO: this may need to be revisited, but works fine for Rossetti Archive)
      filename = File.expand_path(url.gsub(/\//,'_'), dir) # replace forward-slashes as they interfere as a filename
   
      if !File.exist?(filename)
         logger.info "For #{id} fetching #{url}..."
         
         begin
            response = WebUtils.fetch_html(url)
   
            # save response to local file
            File.open(filename, "w") {|f| f.puts response.body}
         rescue Net::HTTPServerException => e
            logger.warn "Could not fetch #{url}.  [#{e}]"
         end
      else
         logger.debug "Skipping #{url} for #{id}, already fetched."
      end
   end
end

