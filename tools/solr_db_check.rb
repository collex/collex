##########################################################################
# Copyright 2007 Applied Research in Patacriticism and the University of Virginia
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################

require 'solr'
solr = Solr::Connection.new(SOLR_URL)
response = eval(solr.post_to_solr("wt=ruby&q=type:C&rows=1000"))
raw_solr_docs = response['response']['docs']
raw_db_docs = Interpretation.find(:all)
solr_docs = raw_solr_docs.collect {|doc| {:username=>doc['username'], :uri =>doc['object_uri']}}
db_docs = raw_db_docs.collect {|doc| {:username => doc.user.username, :uri => doc.object_uri}}
diff = db_docs.select {|doc| not solr_docs.include?(doc)}

solr_uris = raw_solr_docs.collect {|d| d['uri']}
db_uris = raw_db_docs.collect {|d| "#{d.object_uri}/#{d.user.username}"}

solr_counts = {}
solr_uris.each {|d| solr_counts[d] ||= 0; solr_counts[d] += 1 }
db_counts = {}
db_uris.each {|d| db_counts[d] ||= 0; db_counts[d] += 1 }
solr_dups = solr_counts.find_all {|k,v| v > 1}
db_dups = db_counts.find_all {|k,v| v > 1}

#  db_dups.each {|a| t=a[0]; uri = t.sub(/\/[^\/]*$/,'');  Interpretation.delete_all("object_uri = '#{uri}'"); }

in_db_not_solr = raw_db_docs.reject do |dbdoc|
  solrdoc = raw_solr_docs.find {|d| (d['object_uri'] === dbdoc.object_uri) && (d['username'] === dbdoc.user.username)}
  solrdoc.nil? ? false : true
end

in_solr_not_db = raw_solr_docs.reject do |solrdoc|
  raw_db_docs.find {|d| solrdoc['object_uri'] == d.object_uri && solrdoc['username'] == d.user.username}
end

users = User.find(:all)
# TODO: there is no longer a "collected" field.  rather use an expression of username:[* TO *]
facets = solr.facet('username', [{:field => "collected", :value => "collected"}])
solr_counts = {}
db_counts = {}
users.each do |u|
  count = eval(solr.post_to_solr("qt=standard&wt=ruby&rows=1000&q=type:C+AND+username:#{u.username}"))['response']['numFound']
  solr_counts[u.username] = count if count > 0
  db_counts[u.username] = u.interpretations.size if u.interpretations.size > 0
end
count_diffs = solr_counts.find_all {|k,v| facets[k] != v}




#  in_solr_not_db.each {|d| solr.remove_collectables(d['username'],d['object_uri'])}