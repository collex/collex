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

namespace :solr_test do

	desc "Reindex documents from the rdf folder to the reindex core [folder] (solr must be started, and the base folders must be set in site.yml)"
	task :reindex  => :environment do
		# TODO: set folders in site.yml
		rdf_location = '../rdf/'
		# TODO: how to set parameters
		folder = '19'
		clear = false
		puts "~~~~~~~~~~~ Reindexing solr documents..."
		start_time = Time.now
		if clear
			# TODO: clear the reindexing index
		end
		#TODO: start the reindexer
		#`cd ../solr_1.3 && #{JAVA_PATH}java -Djetty.port=8983 -DSTOP.PORT=8079 -DSTOP.KEY=c0113x -jar start.jar &`
		puts "Finished in #{Time.now-start_time} seconds."
	end

	desc "compare the main index with the reindexed one"
	task :compare_indexes  => :environment do
		page = ENV['page']
		page = 1 if page == nil
		puts "~~~~~~~~~~~ Comparing documents..."
		start_time = Time.now
		CollexEngine.compare_reindexed_core(page.to_i)
		puts "Finished in #{Time.now-start_time} seconds."

		# TODO: have a caching mechanism when we get more than a single archive at a time
		# Get core documents, sorted by uri

		# Get reindexed documents, sorted by uri

		# Compare documents - left-orphan, right-orphan, and a mismatch fields.
		# Writes a status to stdout as it goes (can we use \r to stop \n?)
		# Writes errors to a log file.
		# Reports error if the number of records is different in each core
	end

	desc "clear the reindexing index"
	task :clear_reindexing_index  => :environment do
		puts "~~~~~~~~~~~ Clearing reindexing index..."
		start_time = Time.now
		reindexed = CollexEngine.new(['reindex_resources'])
		reindexed.clear_index()
		puts "Finished in #{Time.now-start_time} seconds."
	end

	desc "delete an archive from the reindexing index"
	task :delete_archive_from_index  => :environment do
		archive = ENV['archive']
		if archive == nil || archive.length == 0
			puts "Pass the archive name to this task"
		else
			puts "~~~~~~~~~~~ Deleting archive: #{archive}..."
			start_time = Time.now
			reindexed = CollexEngine.new(['reindex_resources'])
			reindexed.delete_archive(archive)
			puts "Finished in #{Time.now-start_time} seconds."
		end
	end

	desc "Look for duplicate objects in rdf arg: (folder=subfolder under rdf to scan)"
	task :find_duplicate_objects => :environment do
		folder = ENV['folder']
		folder = '/' + folder if folder
		puts "~~~~~~~~~~~ Searching for duplicates in \"../rdf#{folder}\" ..."
		start_time = Time.now
		#count = 0
		puts "creating folder list..."
		directories = get_folder_tree("../rdf#{folder}", [])

		directories.each{|dir|
			puts "scanning #{dir} ..."
			#tim = Time.now
			#all_objects_raw = `grep "rdf:about" #{dir}/*`	# just do one folder at a time so that grep isn't overwhelmed.
			#all_objects_raw = `cd #{dir} && ls * | xargs grep "rdf:about"`	# just do one folder at a time so that grep isn't overwhelmed.
			all_objects_raw = `find #{dir}/* -print0 -maxdepth 0 | xargs -0 grep "rdf:about"`	# just do one folder at a time so that grep isn't overwhelmed.
			#puts "finished grep in #{Time.now-tim} seconds..."
			all_objects = {}
			all_objects_raw.each { | obj|
				arr = obj.split(':', 2)
				arr1 = obj.split('rdf:about="', 2)
				arr2 = arr1[1].split('"')
				if all_objects[arr2[0]] == nil
					all_objects[arr2[0]] = arr[0]
				else
 					puts "Duplicate: #{arr2[0]} in #{all_objects[arr2[0]]} and #{arr[0]}"
				end
				#count += 1
				#puts "Number scanned: #{count}" if count % 1000 == 0

			}
		}
		puts "Finished in #{Time.now-start_time} seconds."
	end

	def get_folder_tree(starting_dir, directories)
		#define a recursive function that will traverse the directory tree
		# unfortunately, it looks like, at least for OS X and stuff that is returned from SVN, that file? and directory? don't work, so we have some workarounds
		begin
			has_file = false
			Dir.foreach(starting_dir) { |name|
				if !File.file?(name) && name[0] != 46 && name != 'nbproject' && name.index('.rdf') == nil && name.index('.xml') == nil && name.index('.txt') == nil
					path = "#{starting_dir}/#{name}"
					#puts "DIR: #{path}"
					directories = get_folder_tree(path, directories)
				end
				has_file = true if name.index('.rdf') != nil || name.index('.xml') != nil
			}
	    directories << starting_dir if has_file
		rescue
			# just ignore if it doesn't work.
		end
		return directories
  end
#	desc "Restart solr"
#	task :restart => :environment do
#		Rake::Task['solr:stop'].invoke
#		Rake::Task['solr:start'].invoke
#	end

end

