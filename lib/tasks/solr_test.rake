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

require 'script/lib/marc_indexer.rb'
namespace :solr_test do

	desc "Completely reindex and test all RDF and MARC records"
	task :completely_reindex_everything => :environment do
		# Use this when there is a change to the schema to completely rebuild the index, then print out the differences between the new
		# and old indexes.

		puts "~~~~~~~~~~~ Completely reindex everything..."
		start_time = Time.now
		# recreate all the RDF data
		ENV['index'] = 'reindex_rdf'
		Rake::Task['solr_test:clear_reindexing_index'].invoke
		Rake::Task['solr_test:reindex_rdf'].invoke

		# recreate all the MARC data
		ENV['index'] = 'reindex_marc'
		Rake::Task['solr_test:clear_reindexing_index'].invoke
		Rake::Task['solr_test:reindex_marc'].invoke

		# Now, test the indexes
		Rake::Task['solr_test:scan_for_missed_objects'].invoke	# see if there are different objects in the two indexes
		Rake::Task['solr_test:compare_indexes'].invoke	# list the differences between the objects
		Rake::Task['solr_test:find_duplicate_objects'].invoke	# see if there are any duplicate uri anywhere in the RDF records.

		puts "Finished in #{(Time.now-start_time)/60} minutes."
	end

	desc "Reindex documents from the rdf folder to the reindex core [folder] (solr must be started, and the base folders must be set in site.yml)"
	task :reindex_rdf  => :environment do
		folder = ENV['folder']
		folder = '' if folder == nil
		# TODO: set folders in site.yml
		rdf_path = '../rdf/'
		indexer_path = '../indexer'

		path = "#{rdf_path}#{folder}"
		puts "~~~~~~~~~~~ Reindexing solr documents in #{path}..."
		puts "(see #{indexer_path}/indexer.log for progress information.)"
		puts "(see #{indexer_path}/#{folder}_report.txt for error information.)"
		start_time = Time.now

		`cd #{indexer_path} && java -Xmx1500m -jar rdf-indexer.jar #{path} --reindex`
		puts "Finished in #{(Time.now-start_time)/60} minutes."
	end

	desc "Reindex all MARC records (optional param: archive=[bancroft|lilly])"
	task :reindex_marc => :environment do
		archive = ENV['archive']
		marc_path = '../marc/'
		indexer_path = '../indexer'
		puts "~~~~~~~~~~~ Reindexing marc records..."
		start_time = Time.now
			args = { :dir => "#{marc_path}Uva",
                # :output_file => 'extracted.mrc',
                 :url_log_path => 'link_data.txt',
                 :tool => :index,
                 :solr_url => 'http://localhost:8983/solr/reindex_marc',
                 :forgiving => true,
                 :debug => false,
                 :verbose => false,
								 :target_uri_file => 'script/uva_uri.rb',
								 :archive => 'uva_library'
               }
		#MarcIndexer.run(args) # Don't do the uva library at the moment until we figure out how
		args[:target_uri_file] = nil

		if archive == nil || archive == 'bancroft'
			args[:archive] = 'bancroft'
			args[:dir] = "#{marc_path}Bancroft"
			MarcIndexer.run(args)
		end

		if archive == nil || archive == 'lilly'
			args[:archive] = 'lilly'
			args[:dir] = "#{marc_path}Lilly"
			MarcIndexer.run(args)
		end
		puts "Finished in #{(Time.now-start_time)/60} minutes."
	end

	desc "Creates an RDF with all available information from all objects in the specified archive"
	task :recreate_rdf_from_index  => :environment do
		# This was created to get the UVA MARC records out of the index when we couldn't recreate the uva MARC records.
		rdf_path = '../rdf/'
		archive = ENV['archive']
		if archive == nil
			puts "Usage: Pass in an archive name with archive=XXX; there should be a folder of the same name under #{rdf_path}"
		else
			puts "~~~~~~~~~~~ Recreating RDF for the #{archive} archive..."
			start_time = Time.now
			resources= CollexEngine.new(['resources'])
			all_recs = resources.get_all_objects_in_archive(archive)
			RegenerateRdf.regenerate_all(all_recs, rdf_path+archive, archive)
			puts "Finished in #{(Time.now-start_time)/60} minutes."
		end
	end

	desc "Get list of objects not reindexed"
	task :scan_for_missed_objects => :environment do
		puts "~~~~~~~~~~~ Scanning for missed documents..."
		start_time = Time.now
		CollexEngine.get_list_of_skipped_objects()
		puts "Finished in #{(Time.now-start_time)/60} minutes."
	end

	desc "compare the main index with the reindexed one (optional parameter: archive=XXX or start_after=XXX)"
	task :compare_indexes  => :environment do
		archive = ENV['archive']
		start_after = ENV['start_after']
		puts "~~~~~~~~~~~ Comparing documents from the original index with the reindexed indexes..."
		start_time = Time.now
		CollexEngine.compare_reindexed_core({ :archive => archive, :start_after => start_after })
		puts "Finished in #{(Time.now-start_time)/60} minutes."

		# TODO: have a caching mechanism when we get more than a single archive at a time
		# Get core documents, sorted by uri

		# Get reindexed documents, sorted by uri

		# Compare documents - left-orphan, right-orphan, and a mismatch fields.
		# Writes a status to stdout as it goes (can we use \r to stop \n?)
		# Writes errors to a log file.
		# Reports error if the number of records is different in each core
	end

	desc "clear the reindexing index (param: index=[reindex_rdf|reindex_marc]"
	task :clear_reindexing_index  => :environment do
		index = ENV['index']
		if index == nil
			puts "Usage: call with index=XXX"
		else
			puts "~~~~~~~~~~~ Clearing reindexing index #{index}..."
			start_time = Time.now
			reindexed = CollexEngine.new([index])
			reindexed.clear_index()
			puts "Finished in #{Time.now-start_time} seconds."
		end
	end

	desc "delete an archive from the RDF reindexing index"
	task :delete_archive_from_index  => :environment do
		archive = ENV['archive']
		if archive == nil || archive.length == 0
			puts "Pass the archive name to this task"
		else
			puts "~~~~~~~~~~~ Deleting archive: #{archive}..."
			start_time = Time.now
			reindexed = CollexEngine.new(['reindex_rdf'])
			reindexed.delete_archive(archive)
			puts "Finished in #{Time.now-start_time} seconds."
		end
	end

	desc "delete an archive from the MARC reindexing index"
	task :delete_archive_from_marc_index  => :environment do
		archive = ENV['archive']
		if archive == nil || archive.length == 0
			puts "Pass the archive name to this task"
		else
			puts "~~~~~~~~~~~ Deleting archive: #{archive}..."
			start_time = Time.now
			reindexed = CollexEngine.new(['reindex_marc'])
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

