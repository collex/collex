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


triples = File.open(ARGV[0]) { |f| YAML::load(f) }
users = File.open(ARGV[1]) { |f| YAML::load(f) }

puts "#{users.size} users"
logger.info "Creating users..."
users.each do |u|
  username = u[:username]
  user = User.find_by_username(username)

  if user
    logger.info "User #{username} already exists"
  else
    user = User.create(:username => username, :password_hash => u[:pwhash], :fullname => u[:fullname], :email => u[:email])
    user.save
  end
end


logger.info "Loading tags and annotations..."
#urn:object:Jared/http://www.rossettiarchive.org/docs/6-1880.blms.rad#0.1.1
object_re = /urn:object:(\w*)\/(.*)/

#urn:tag:LBSC708Y/janes http://purl.org/dc/elements/1.1/relation http://www.rc.umd.edu/praxis/contemporary/mandell/issue_intro.html
tag_re = /urn:tag:(\w*)\/(.*)/

collectables = {}
triples.each do |triple|
  subject = triple[:subject]
  predicate = triple[:predicate]
  object = triple[:object]
  
  if predicate == "http://www.nines.org/schema#annotation"
    if object_re.match(subject)
      username = $1
      uri = $2
      key = "#{username}/#{uri}"
      collectable = collectables.has_key?(key) ? collectables[key] : {:uri => uri, :username => username, :tags => [], :annotation => ""}
      collectable[:annotation] = object
      collectables[key] = collectable
    end
  end
  
  if tag_re.match(subject) and predicate == "http://purl.org/dc/elements/1.1/relation"
    username = $1
    tag = $2
    uri = object

    key = "#{username}/#{uri}"
    collectable = collectables.has_key?(key) ? collectables[key] : {:uri => uri, :username => username, :tags => [], :annotation => ""}
    collectable[:tags] << tag
    collectables[key] = collectable
  end
end

solr = Solr.new
collectables.each do |key, collectable|
  solr.update(collectable[:username], collectable[:uri], collectable[:tags], collectable[:annotation])
end

solr.commit
solr.optimize
