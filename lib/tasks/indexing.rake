namespace :indexing do

	desc "Index all exhibits in this federation into main index."
	task :all_exhibits => :environment do
		puts "~~~~~~~~~~~ Indexing all peer-reviewed exhibits into solr..."
		start_time = Time.now()
		Exhibit.index_all_peer_reviewed()
		finish_line(start_time)
	end

	desc "Index an exhibit in this federation into main index [exhibit_id]."
	task :one_exhibit, [:id] => :environment do |t, args|
		puts "This task is intended only for debugging."
		return
		id = args[:id]
		puts "~~~~~~~~~~~ Indexing exhibit #{id} into solr..."
		start_time = Time.now()
		exhibit = Exhibit.find(id)
		exhibit.index_exhibit(true)
		finish_line(start_time)
	end

	desc "Unindex all exhibits in this federation from the main index."
	task :unindex_all_exhibits => :environment do
		puts "~~~~~~~~~~~ Removing all peer-reviewed exhibits from the solr index..."
		start_time = Time.now()
		Exhibit.unindex_all_exhibits()
		finish_line(start_time)
	end

	desc "Reindex all local content in this federation."
	task :all_local_content => :environment do
		solr = SearchUserContent.new
		solr.reindex_all()
	end

	#desc "Run the user content task that is done in the daemon"
	#task :periodic_user_content => :environment do
	#	result = SearchUserContent.periodic_update()
	#	puts result.to_s
	#end

end