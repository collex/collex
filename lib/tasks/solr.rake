##########################################################################
# Copyright 2009 Applied Research in Patacriticism and the University of Virginia
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

namespace :solr do

	desc "Start the solr java app (Prerequisite for running Collex)"
	task :start  => :environment do
		puts "~~~~~~~~~~~ Starting solr..."
		`cd #{solr_folder()} && #{JAVA_PATH}java -Djetty.port=8983 -DSTOP.PORT=8079 -DSTOP.KEY=c0113x -Xmx1800m -jar start.jar &`
	end
	
	desc "Stop the solr java app"
	task :stop  => :environment do
		puts "~~~~~~~~~~~ Stopping solr..."
		`cd #{solr_folder()} && #{JAVA_PATH}java -Djetty.port=8983 -DSTOP.PORT=8079 -DSTOP.KEY=c0113x -jar start.jar --stop`
		puts "Finished."
	end

	desc "Restart solr"
	task :restart => :environment do
		Rake::Task['solr:stop'].invoke
		Rake::Task['solr:start'].invoke
	end

	def path_of_zipped_index
		path = "~/"	#TODO: set this in site.yml
		today = Time.now()
		return "#{path}#{today.strftime('20%y.%m.%d')}.index.tar.gz"
	end

	desc "Zip up the current index for backup and replication (parameter: index=resources|merged)"
	task :zip => :environment do
		# NOTE: if there are two indexes made in a day, this will overwrite the first one.
		today = Time.now()
		index = ENV["index"]
		if index == nil
			puts "Usage: call with index=CORE_NAME"
		else
			filename = path_of_zipped_index()
			puts "~~~~~~~~~~~ zipping index \"#{index}\" to #{filename}..."
			`cd #{solr_folder()}/solr/data/#{index} && tar cvzf #{filename} index`
			puts "Finished in #{(Time.now-today)/60} minutes."
		end
	end

	desc "Package and copy index to another machine (param: dest=nines@nines.org). The remote machine's password will be requested."
	task :send_index_to_server => :environment do
		today = Time.now()
		dest = ENV['dest']
		if dest == nil
			puts "Usage: call with dest=the ssh login for the destination machine"
		else
			filename = path_of_zipped_index()
			ENV['index'] = 'resources'
			Rake::Task['solr:zip'].invoke
			`scp #{filename} #{dest}:solr_1.4/solr/data/resources`
		end
			puts "Finished in #{(Time.now-today)/60} minutes."
	end

	desc "Index all exhibits into main index (Note: do this only on the production machine. After this step, do not zip up and move this index.)"
	task :index_exhibits => :environment do
		puts "~~~~~~~~~~~ Indexing all peer-reviewed exhibits into solr..."
		today = Time.now()
		Exhibit.index_all_peer_reviewed()
		puts "Finished in #{Time.now-today} seconds."
	end

	desc "Remove exhibits from the main index (in case the index should be zipped up and moved.)"
	task :remove_exhibits_from_index => :environment do
		puts "~~~~~~~~~~~ Removing all peer-reviewed exhibits from solr..."
		today = Time.now()
		Exhibit.unindex_all_exhibits()
		puts "Finished in #{Time.now-today} seconds."
	end

#	desc "Set aside existing good solr index so that experiments can be run"
#	task :set_aside_existing_solr_index => :environment do
#		Rake::Task['solr:stop'].invoke
#		puts "~~~~~~~~~~~ Moving good index out of the way..."
#		`mv #{solr_folder()}/solr/data/index ../good_index_backup`
#		Rake::Task['solr:start'].invoke
#	end

#	desc "Restore the good solr index that was saved with :set_aside_existing_solr_index"
#	task :restore_good_solr_index => :environment do
#		Rake::Task['solr:stop'].invoke
#		puts "~~~~~~~~~~~ Restoring the good solr index..."
#		`rm -r #{solr_folder()}/solr/data/index`
#		`cp -R ../good_index_backup ../#{solr_folder()}/solr/data/index`
#		Rake::Task['solr:start'].invoke
#	end

#	desc "Delete solr index - note: be sure you have a backup first!"
#	task :delete_solr_index => :environment do
#		Rake::Task['solr:stop'].invoke
#		puts "~~~~~~~~~~~ Deleting solr index..."
#		`rm -r #{solr_folder()}/solr/data/index`
#		Rake::Task['solr:start'].invoke
#	end

	desc "Optimize the index passed in [core=XXX]"
	task :optimize => :environment do
		core = ENV['core']
		if core == nil
			puts "Usage: pass in core=XXX"
		else
			puts "~~~~~~~~~~~ Optimize #{core}..."
			start_time = Time.now
			index = CollexEngine.new([core])
			index.optimize()
			puts "Finished in #{(Time.now-start_time)/60} minutes."
		end
	end

	def solr_folder()
		return "../solr_1.4"
	end
end

