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

new_model = ARGV[0]
existing_models = ARGV[1..-1]

logger.info "Merging #{existing_models.join(',')} into the #{new_model} Kowari model"

kowari = Kowari.new

query = "insert select $s $p $o from "
query << existing_models.collect {|model| "#{Kowari.model(model)}"}.join(' and ')
query << " where $s $p $o into #{Kowari.model(new_model)};"

logger.info query

result = kowari.query(query)

