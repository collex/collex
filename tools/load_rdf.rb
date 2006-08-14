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

logger.info "Loading RDF from #{dir} into the #{model_name} Kowari model"

kowari = Kowari.new
model = Kowari.model(model_name)
query = "create #{model};"
result = kowari.query(query)

Dir.foreach(dir) do |filename|
   if filename =~ /\.rdf$/
      logger.info "Loading #{filename}..."
      
#      xml = REXML::Document.new(File.open(File.expand_path(filename, dir)))
#      xml.elements.each("//") do |e|
#        if e.text
#          e.text = e.text.sub(/^[ \t\n]*(.*)[ \t\n]*$/, '\1')
#        end
#      end
      
#      temp_file = Tempfile.new(filename)
#      xml.write(temp_file, 0)
#      temp_file.close
      
      url = "file://#{File.expand_path(filename, dir)}"
      query = "load <#{url}> into #{model};"
      result = kowari.query(query)
   end
end
