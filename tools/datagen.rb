num_objects = 500
max_tags_per_object = 5
#all_tags = %w{war desire hopkins swinburne primary secondary american romanticism poetry pre-raphaelite whitman rossetti victorian painting art beatrix ballad love death beauty}
all_tags = %w{war american poetry whitman death}
all_users = %w{beth erik}
constraints = [{:field => "archive", :value => "whitman"}]

require 'xmlrpc/client'
require 'soap/wsdlDriver'

DRIVER = SOAP::WSDLDriverFactory.new("http://localhost:8080/webservices/services/ItqlBeanService?wsdl").create_driver

def insert_statement(s, p, o, model)
   object = ""
   if o =~ /^http|^urn/
      object = "<#{o}>"
   else
      o.gsub!(/(['|\.])/,'') # remove characters that Kowari needs escaped - haven't gotten escaping to work reliably yet
      object = "'#{o}'"
   end
      
   "insert <#{s}> <#{p}> #{object} into <#{model}>;"
end

def data_insert_statement(s,p,o)
   insert_statement s, p, o, "rmi://localhost/server1#collex"
end

def user_insert_statement(s,p,o)
   insert_statement s, p, o, "rmi://localhost/server1#collex_user"
end

def tag_it(hit, user, tags)
   puts "--> #{user} tagging #{hit['link']} with #{tags.join(',')}"
   
   statements = []
   # Add the object to the collection
   statements << data_insert_statement(hit['uri'], "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", "http://www.rossettiarchive.org/schema#rap")
   statements << data_insert_statement(hit['uri'], "http://purl.org/dc/elements/1.1/title", hit['title'])
   statements << data_insert_statement(hit['uri'], "http://purl.org/dc/elements/1.1/type", hit['type']) if hit['type']
   statements << data_insert_statement(hit['uri'], "http://www.w3.org/2000/01/rdf-schema#seeAlso", hit['link']) if hit['link']
   statements << data_insert_statement(hit['uri'], "http://purl.org/dc/elements/1.1/date", hit['date']) if hit['date']
   statements << data_insert_statement(hit['uri'], "http://purl.org/dc/elements/1.1/creator", hit['creator']) if hit['creator']
   statements << data_insert_statement(hit['uri'], "http://www.nines.org/schema#thumbnail", hit['thumbnail']) if hit['thumbnail']

   # tag the object
   statements << user_insert_statement("urn:user:#{user}", "http://purl.org/dc/elements/1.1/relation", hit['uri'])

   tags.each do |tag|
      statements << user_insert_statement("urn:tag:#{user}/#{tag}", "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", "http://www.patacriticism.org/collex/schema#Tag")
      statements << user_insert_statement("urn:tag:#{user}/#{tag}", "rdfs:label", tag)
      statements << user_insert_statement("urn:tag:#{user}/#{tag}", "http://purl.org/dc/elements/1.1/creator", "urn:user:#{user}")
      statements << user_insert_statement("urn:tag:#{user}/#{tag}", "http://purl.org/dc/elements/1.1/relation", hit['uri'])
   end

   query = statements.join(' ')
   puts statements.join("\n")
   DRIVER.executeQueryToString(query)
end

server = XMLRPC::Client.new2("http://localhost:8076")
results = server.call("search", constraints, 1, num_objects)

results["hits"].each do |hit|
   if hit['thumbnail']
     all_users.each do |user|
        # flip a coin on each user
        if rand(2) == 1
           #    pick a random number of unique tags
           num_tags = rand(max_tags_per_object)
           tags = []
           for i in 1..num_tags
              tags << all_tags[rand(all_tags.length)]
           end

           #      add hit to Kowari, metadata and user tag info
           tag_it hit, user, tags.uniq         
        end
     end
   end
end



