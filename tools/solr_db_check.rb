solr = Solr.new
response = eval(solr.post_to_solr("wt=ruby&q=type:C&rows=500"))
raw_solr_docs = response['response']['docs']
raw_db_docs = Interpretation.find(:all)
solr_docs = raw_solr_docs.collect {|doc| {:username=>doc['username'], :uri =>doc['object_uri']}}
db_docs = raw_db_docs.collect {|doc| {:username => doc.user.username, :uri => doc.object_uri}}
diff = db_docs.select {|doc| not solr_docs.include?(doc)}