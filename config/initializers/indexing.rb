# load all the site specific stuff
config_file = File.join(Rails.root, "config", "site.yml")
if File.exists?(config_file)
	site_specific = YAML.load_file(config_file)
	JAVA_PATH = site_specific['java_path']
	CAN_INDEX = site_specific['can_index'] == nil ? false : site_specific['can_index']
	SVN_COLLEX = site_specific['svn']['url_collex']
	SVN_RDF = site_specific['svn']['url_rdf']
	folders = site_specific['folders']
	if folders
		RDF_PATH = folders['rdf']
		MARC_PATH = folders['marc']
		ECCO_PATH = folders['ecco']
		INDEXER_PATH = folders['rdf_indexer']
	end
else
	puts "***"
	puts "*** Failed to load site configuration. Did you create config/site.yml?"
	puts "***"
end

if JAVA_PATH.length > 0
	puts "$$ Java path explicitly set to: #{JAVA_PATH}"
end
