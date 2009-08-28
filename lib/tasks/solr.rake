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

	desc "Start the solr java app (Prerequisite for running NINES)"
	task :start  => :environment do
		`cd ../solr_1.3 && #{JAVA_PATH}java -Djetty.port=8983 -DSTOP.PORT=8079 -DSTOP.KEY=c0113x -jar start.jar &`
	end
	
	desc "Stop the solr java app"
	task :stop  => :environment do
		`cd ../solr_1.3 && #{JAVA_PATH}java -Djetty.port=8983 -DSTOP.PORT=8079 -DSTOP.KEY=c0113x -jar start.jar --stop`
	end

	desc "Run the solr indexer on the files that are in the rdf folder"
	task :run_indexer => :environment do
#		`cp ../rdf-indexer/dist/rdf-indexer.jar ../indexer/rdf-indexer.jar`
#		`cd ../indexer && #{JAVA_PATH}java -jar rdf-indexer.jar rdf  &`
		`cd ../indexer && #{JAVA_PATH}java -jar ../rdf-indexer/dist/rdf-indexer.jar rdf`
	end

	desc "Restart solr"
	task :restart => :environment do
		Rake::Task['solr:stop'].invoke
		Rake::Task['solr:start'].invoke
	end

	desc "Set aside existing good solr index so that experiments can be run"
	task :set_aside_existing_solr_index => :environment do
		Rake::Task['solr:stop'].invoke
		`mv ../solr_1.3/solr/data/index ../good_index_backup`
		Rake::Task['solr:start'].invoke
	end

	desc "Restore the good solr index that was saved with :set_aside_existing_solr_index"
	task :restore_good_solr_index => :environment do
		Rake::Task['solr:stop'].invoke
		`rm -r ../solr_1.3/solr/data/index`
		`cp -R ../good_index_backup ../solr_1.3/solr/data/index`
		Rake::Task['solr:start'].invoke
	end

	desc "Delete solr index - note: be sure you have a backup first!"
	task :delete_solr_index => :environment do
		Rake::Task['solr:stop'].invoke
		`rm -r ../solr_1.3/solr/data/index`
		Rake::Task['solr:start'].invoke
	end


	desc "Completely reindex everything without full search (wipes out current index)"
	task :completely_reindex => :environment do
		Rake::Task['solr:delete_solr_index'].invoke
		Rake::Task['solr:run_indexer'].invoke
	end
end

