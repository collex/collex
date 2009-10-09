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

	desc "Zip up the current index for backup and replication"
	task :zip => :environment do
		# TODO: if there are two indexes made in a day, this will overwrite the first one.
		path = "~/"	#TODO: set this in site.yml
		today = Time.now()
		filename = "#{path}#{today.strftime('%m.%d.%y')}.index.tar.gz"
		puts "~~~~~~~~~~~ zipping index to #{filename}..."
	`cd #{solr_folder()}/solr/data/resources && tar cvzf #{filename} index`
	#`gzip #{filename}`
	puts "Finished in #{(Time.now-today)/60} minutes."

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

