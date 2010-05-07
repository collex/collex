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

namespace :solr_index do

	desc "Reindex all user content"
	task :reindex_all_user_content => :environment do
		solr = SearchUserContent.new
		solr.reindex_all()
	end

	desc "Temp task for a batch file"
	task :temp => :environment do
		puts "TASK"
		start_time = Time.now
		#ENV['archive'] = "JSTOR:American Literary History;JSTOR:American Literature;JSTOR:NOVEL: A Forum on Fiction;JSTOR:Nineteenth-Century Fiction;JSTOR:Nineteenth-Century Literature;JSTOR:Studies in English Literature, 1500-1900;JSTOR:Trollopian"
		#ENV['archive'] = "uva_library;cbw"
		#Rake::Task['solr_index:merge_archive'].invoke

		#ENV['archive'] = "bancroft"
		#Rake::Task['solr_index:reindex_marc'].invoke
		#CollexEngine.compare_reindexed_core_text({ :archive => "bancroft", :start_after => nil, :use_merged_index => false })
		#CollexEngine.compare_reindexed_core({ :archive => "bancroft", :start_after => nil, :use_merged_index => false })
		puts "Finished in #{(Time.now-start_time)/60} minutes."
	end

	desc "Completely reindex and test all RDF and MARC records"
	task :completely_reindex_everything => :environment do
		# Use this when there is a change to the schema to completely rebuild the index, then print out the differences between the new
		# and old indexes.

		puts "~~~~~~~~~~~ Completely reindex everything..."
		start_time = Time.now
		# clear all the indexes
		archives = CollexEngine.get_archive_core_list()
		archives.each{|archive|
			reindexed = CollexEngine.new([archive])
			reindexed.clear_index()
			puts "cleared index #{archive}"
		}
		# recreate all the RDF data
		ENV['folder'] = ''
		Rake::Task['solr_index:reindex_rdf'].invoke

		# recreate all the MARC data
		ENV['archive'] = nil
		Rake::Task['solr_index:reindex_marc'].invoke

		# Now, test the indexes
		Rake::Task['solr_index:scan_for_missed_objects'].invoke	# see if there are different objects in the two indexes
		ENV['start_after'] = nil
		Rake::Task['solr_index:compare_indexes'].invoke	# list the differences between the objects
		Rake::Task['solr_index:find_duplicate_objects'].invoke	# see if there are any duplicate uri anywhere in the RDF records.
		Rake::Task['solr_index:compare_indexes_text'].invoke	# list the differences between the text in the objects

		puts "Finished in #{(Time.now-start_time)/60} minutes."
	end

	desc "reindex and test one archive (param: archive=archive,folder)"
	task :reindex_and_test_one_archive => :environment do
		start_time = Time.now
		param = ENV['archive']
		if param == nil
			puts "Usage: call with archive=archive,folder"
			return
		end
		arr = param.split(',')
		folder = arr[1]
		archive = arr[0]
		if folder == nil || folder.length == 0 || archive == nil || archive.length == 0
			puts "Usage: call with archive=archive,folder"
		else
			ENV['folder'] = folder
			Rake::Task['solr_index:reindex_rdf'].invoke
			ENV['archive'] = archive
			Rake::Task['solr_index:compare_indexes'].invoke	# list the differences between the objects
			ENV['archive'] = archive
			Rake::Task['solr_index:compare_indexes_text'].invoke	# list the differences between the text in the objects
		end
		puts "Finished in #{(Time.now-start_time)/60} minutes."
	end

	desc "Compare archive_* indexes with original index (optional param: archive=XXX)"
	task :compare_archive_index_with_original_index => :environment do
		Rake::Task['solr_index:scan_for_missed_objects'].invoke	# see if there are different objects in the two indexes
		#ENV['start_after'] = "bancroft" #nil
		Rake::Task['solr_index:compare_indexes'].invoke	# list the differences between the objects
		#ENV['start_after'] = "chesnutt"
		Rake::Task['solr_index:compare_indexes_text'].invoke	# list the differences between the text in the objects
	end

	desc "Compare merged index with original index (optional param: archive=XXX)"
	task :compare_merged_index_with_original_index => :environment do
		ENV['use_merged_index'] = "true"
		Rake::Task['solr_index:scan_for_missed_objects'].invoke	# see if there are different objects in the two indexes
		Rake::Task['solr_index:compare_indexes'].invoke	# list the differences between the objects
		Rake::Task['solr_index:compare_indexes_text'].invoke	# list the differences between the text in the objects
	end

	desc "Reindex documents from the rdf folder to the reindex core (optional params: folder=XXX or start_after=XXX)"
	task :reindex_rdf  => :environment do
		total_start_time = Time.now
		folder = ENV['folder']
		start_after = ENV['start_after']

		# TODO: set folders in site.yml
		rdf_path = '../rdf'
		if folder == nil || folder.length == 0
			# if we are reindexing everything, do it folder by folder. That way there is less memory requirements
			# on the indexer program, and if the indexer fails, then only that one folder will fail.
			folders = get_folder_tree("#{rdf_path}", [])
		else
			folders = [ "#{rdf_path}/#{folder}" ]
		end

		indexer_path = 'rdf-indexer'
		started = start_after == nil
		folders.each{|path|
			if started
				call_rdf_indexer("Reindexing solr documents in", path, "--reindex")
			else
				started = folder == start_after
			end
		}
		puts "Finished in #{(Time.now-total_start_time)/60} minutes."
	end

	desc "Do the initial indexing of a folder to the archive_* core (param: folder=XXX)"
	task :index_rdf_for_debugging  => :environment do
		folder = ENV['folder']
		if folder == nil || folder.length == 0
			puts "Usage: pass folder=XXX to index a folder"
		else
			call_rdf_indexer("Initial indexing test for", "../rdf/#{folder}", "")
		end
	end

	desc "Do the full indexing of a folder to the archive_* core. This will spider the archive for the full text. (param: folder=XXX)"
	task :index_rdf_with_fulltext  => :environment do
		folder = ENV['folder']
		if folder == nil || folder.length == 0
			puts "Usage: pass folder=XXX to index a folder"
		else
			call_rdf_indexer("Indexing solr documents in", "../rdf/#{folder}", "--fulltext")
		end
	end

	desc "Uses the current record and goes to the web site to refresh the fulltext field (param: p=core,uri)"
	task :refresh_text  => :environment do
		start_time = Time.now
		p = ENV['p']
		p2 = p.split(',')
		if p2.length != 2
			puts "Usage: pass p=core,uri to refresh the text of that uri in that index"
		else
			require 'script/lib/refresh_doc.rb'
			RefreshDoc.run({ :uri => p2[1], :verbose => true, :core => p2[0] })
		end
			puts "Finished in #{(Time.now-start_time)/60} minutes."
end

	desc "Commits all pending writes on a particular archive (param: archive=XXX)"
	task :commit  => :environment do
		start_time = Time.now
		archive = ENV['archive']
		if archive == nil
			puts "Usage: pass archive=core to to commit pending changes"
		else
			core = CollexEngine.new([archive])
			core.commit()
		end
			puts "Finished in #{(Time.now-start_time)/60} minutes."
end

	def call_rdf_indexer(msg, path, flags)
		# TODO: set folders in site.yml
		rdf_path = "#{RAILS_ROOT}/"
		indexer_path = "#{RAILS_ROOT}/lib/tasks/rdf-indexer"
		arr = path.split('/')
		report_name = arr.last()
		puts "~~~~~~~~~~~ #{msg} #{path} [see log/#{report_name}_indexer.log and log/#{report_name}_report.txt]"
		start_time = Time.now

		exist = File.exists?("#{rdf_path}#{path}")
		if !exist
			puts "The folder name #{path} does not exist in the RDF folder."
		else
			puts "cd #{indexer_path} && java -Xmx1500m -jar dist/rdf-indexer.jar #{rdf_path}#{path} #{flags}"
			`cd #{indexer_path} && java -Xmx1500m -jar dist/rdf-indexer.jar #{rdf_path}#{path} #{flags}`
			puts "Finished in #{(Time.now-start_time)/60} minutes."
		end
	end

	desc "Create the Gale objects from ESTC"
	task :process_gale_objects => :environment do
		if CAN_INDEX
			require 'script/lib/process_gale_objects.rb'
			include ProcessGaleObjects
			CollexEngine.create_core("archive_ECCO")
			src = CollexEngine.new(["archive_estc"])
			puts "Number of objects: #{src.num_docs()}"
			dst = CollexEngine.new(["archive_ECCO"])
			path = "../ecco/"
			count = 0
			GALE_OBJECTS.each {|arr|
				filename = arr[0]
				text = ''
				File.open("#{path}#{filename}.txt", "r") { |f|
					text = f.read
				}
				uri = arr[1]
				obj = src.get_object(uri)
				if obj == nil
					puts "Can't find object: #{uri}"
				else
					obj['text'] = text
					obj['archive'] = "ECCO"
					obj['url'] = []
					uri = obj['uri']
					obj['uri'] = uri.sub("lib://estc", "lib://ECCO")
					dst.add_object(obj, nil)
				end
				count += 1
				puts "Processed: #{count}" if count % 100 == 0
			}
			dst.commit()
			dst.optimize()
		end
	end

	desc "Reindex all MARC records (optional param: archive=[bancroft|lilly|estc][;max_records])"
	task :reindex_marc => :environment do
		if CAN_INDEX
			require 'script/lib/marc_indexer.rb'
			archive = ENV['archive']
			max_records = nil
			if archive
				arr = archive.split(';')
				archive = arr[0]
				max_records = arr[1] if arr.length > 1
			end
			marc_path = '../marc/'
			puts "~~~~~~~~~~~ Reindexing marc records..."
			start_time = Time.now
				args = { :tool => :index,
									 :forgiving => true,
									 :debug => false,
									 :verbose => false,
									 :max_records => max_records
								 }
			#args[:target_uri_file] = nil

			if archive == nil || archive == 'bancroft'
				args[:archive] = 'bancroft'
				args[:solr_url] = "#{SOLR_URL}/archive_bancroft"
				args[:url_log_path] = 'log/bancroft_link_data.txt'
				args[:federation] = 'NINES'
				CollexEngine.create_core("archive_bancroft")
				args[:dir] = "#{marc_path}Bancroft"
				MarcIndexer.run(args)
			end

			if archive == nil || archive == 'lilly'
				args[:archive] = 'lilly'
				args[:solr_url] = "#{SOLR_URL}/archive_lilly"
				args[:url_log_path] = 'log/lilly_link_data.txt'
				args[:federation] = 'NINES'
				CollexEngine.create_core("archive_lilly")
				args[:dir] = "#{marc_path}Lilly"
				MarcIndexer.run(args)
			end

			if archive == nil || archive == 'estc'
				arc = 'estc'
				args[:archive] = arc
				args[:solr_url] = "#{SOLR_URL}/archive_#{arc}"
				args[:url_log_path] = "log/#{arc}_link_data.txt"
				args[:federation] = nil	# this is calculated for each record
				CollexEngine.create_core("archive_#{arc}")
				args[:dir] = "#{marc_path}#{arc}"
				MarcIndexer.run(args)
			end

			if archive == nil || archive == 'galeDLB'
				arc = 'galeDLB'
				args[:archive] = arc
				args[:solr_url] = "#{SOLR_URL}/archive_#{arc}"
				args[:url_log_path] = "log/#{arc}_link_data.txt"
				args[:federation] = 'NINES'
				CollexEngine.create_core("archive_#{arc}")
				args[:dir] = "#{marc_path}#{arc}"
				MarcIndexer.run(args)
			end
			puts "Finished in #{(Time.now-start_time)/60} minutes."
		end
	end

	desc "Analyze MARC records (param: archive=[bancroft|lilly|estc][;max_records])"
	task :analyze_marc => :environment do
		if CAN_INDEX
			require 'script/lib/marc_indexer.rb'
			archive = ENV['archive']
			max_records = nil
			if archive
				arr = archive.split(';')
				archive = arr[0]
				max_records = arr[1] if arr.length > 1
			end
			marc_path = '../marc/'
			if archive == nil
				puts "Usage: Pass in an archive name with archive=XXX; there should be a folder of the same name under #{marc_path}"
			else
				puts "~~~~~~~~~~~ Scanning #{"the first #{max_records} " if max_records != nil}marc records in #{archive}..."
				start_time = Time.now
					args = { :tool => :index,
										:forgiving => true,
										:debug => true,
										:verbose => true,
										:archive => archive,
										:solr_url => "#{SOLR_URL}/archive_#{archive}",
										:url_log_path => "log/#{archive}_link_data.txt",
										:federation => 'NINES',	# this is calculated for each record
										:dir => "#{marc_path}#{archive}",
										:max_records => max_records
										}
				MarcIndexer.run(args)

				puts "Finished in #{(Time.now-start_time)/60} minutes."
			end
		end
	end

	desc "Scan MARC records for genres (param: archive=[bancroft|lilly|estc][;max_records])"
	task :marc_genre_scanner => :environment do
		if CAN_INDEX
			require 'script/lib/marc_genre_scanner.rb'
			marc_path = '../marc/'
			archive = ENV['archive']
			max_records = nil
			if archive
				arr = archive.split(';')
				archive = arr[0]
				max_records = arr[1] if arr.length > 1
			end
			if archive == nil
				puts "Usage: Pass in an archive name with archive=XXX; there should be a folder of the same name under #{marc_path}"
			else
				puts "~~~~~~~~~~~ Scanning for genres in #{archive}..."
				start_time = Time.now
				MarcGenreScanner.run("#{marc_path}#{archive}", true, max_records)
				puts "Finished in #{(Time.now-start_time)/60} minutes."
			end
		end
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

	desc "Get list of objects not reindexed (optional param: use_merged_index=true, archive=XXX)"
	task :scan_for_missed_objects => :environment do
		use_merged_index = ENV['use_merged_index']
		use_merged_index = (use_merged_index != nil && (use_merged_index == "true" || use_merged_index == true))
		archive = ENV['archive']
		puts "~~~~~~~~~~~ Scanning for missed documents #{archive ? "("+archive+" only) " : ""}in #{use_merged_index ? 'merged' : 'archive_*'} index..."
		start_time = Time.now
		CollexEngine.get_list_of_skipped_objects({ :use_merged_index => use_merged_index, :archive => archive })
		puts "Finished in #{(Time.now-start_time)/60} minutes."
	end

	desc "compare the main index with the reindexed one (optional parameter: archive=XXX or start_after=XXX or use_merged_index=true)"
	task :compare_indexes  => :environment do
		archive = ENV['archive']
		start_after = ENV['start_after']
		use_merged_index = ENV['use_merged_index']
		use_merged_index = (use_merged_index != nil && (use_merged_index == "true" || use_merged_index == true))
		puts "~~~~~~~~~~~ Comparing documents from the original index with the #{use_merged_index ? 'merged' : 'archive_*'} index..."
		start_time = Time.now
		CollexEngine.compare_reindexed_core({ :archive => archive, :start_after => start_after, :use_merged_index => use_merged_index })
		puts "Finished in #{(Time.now-start_time)/60} minutes."
	end

	desc "compare the text in the main index with the reindexed one (optional parameter: archive=XXX or start_after=XXX or use_merged_index=true)"
	task :compare_indexes_text  => :environment do
		archive = ENV['archive']
		start_after = ENV['start_after']
		use_merged_index = ENV['use_merged_index']
		use_merged_index = (use_merged_index != nil && (use_merged_index == "true" || use_merged_index == true))
		#use_merged_index = true	# TODO: temp until I figure out how to pass two params
		puts "~~~~~~~~~~~ Comparing documents from the original index with the #{use_merged_index ? 'merged' : 'archive_*'} index..."
		start_time = Time.now
		CollexEngine.compare_reindexed_core_text({ :archive => archive, :start_after => start_after, :use_merged_index => use_merged_index })
		puts "Finished in #{(Time.now-start_time)/60} minutes."
	end

	def trans_str(str)
		ret = ""
		str.to_s.each_char(){ |ch|
			"#{ch}".each_byte { |c|
				if (c >= 32 && c <= 127) || c == 10
					ret += ch
				else
					ret += "~#{c}~"
				end
			}
		}
		return ret
	end

	def dump_hit(label, hit)
		puts " ------------------------------------------------ #{label} ------------------------------------------------------------------"
		hit.each { |key,val|
			if val.kind_of?(Array)
				val.each{ |v|
					#puts "#{key}: #{trans_str(v)}"
					puts "#{key}: #{v}"
				}
			else
				#puts "#{key}: #{trans_str(val)}"
				puts "#{key}: #{val}"
			end
		}
	end

	desc "examine solr document (param: uri)"
	task :examine_solr_document  => :environment do
		uri = ENV['uri']
		solr = CollexEngine.new()
		hit = solr.get_object_with_text(uri)
		if hit == nil
			puts "#{uri}: Can't find this object in the archive."
			solr = CollexEngine.factory_create(true)
			hit = solr.get_object_with_text(uri)
			dump_hit("ARCHIVE", hit)
		else
			dump_hit("RESOURCES", hit)

			archive = "archive_#{CollexEngine.archive_to_core_name(hit['archive'])}"
			solr = CollexEngine.new([archive])
			hit = solr.get_object_with_text(uri)
			if hit == nil
				puts "#{uri}: Can't find this object in the archive."
			else
				dump_hit("ARCHIVE", hit)
			end
		end
	end

	desc "clear the reindexing index (param: index=[archive_*]"
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

	desc "copy rdf-indexer file for packaging (first build it normally before running this!)"
	task :copy_rdf_indexer => :environment do
		start_time = Time.now
		indexer_path = "#{RAILS_ROOT}/../rdf-indexer"
		src = "#{indexer_path}/dist"
		dst = "#{RAILS_ROOT}/lib/tasks/rdf-indexer"
		puts "~~~~~~~~~~~ Copying #{src} to #{dst}..."
		begin
	    Dir.mkdir("#{dst}")
		rescue
			# It's ok to fail: it probably means the folder already exists.
		end
		`cp -R #{src} #{dst}`
		puts "Finished in #{Time.now-start_time} seconds."
	end

	desc "replace resources index with the merged index"
	task :replace_resources_with_merged => :environment do
		start_time = Time.now
		root = RAILS_ROOT[0..RAILS_ROOT.rindex('/')]
		solr_data_path = "#{root}solr_1.4/solr/data"
		src = "#{solr_data_path}/merged/index"
		dst = "#{solr_data_path}/resources/index"
		puts "~~~~~~~~~~~ Copying #{src} to #{dst}..."
		`sudo /sbin/service solr stop`
		`sudo rm #{dst}/*`
		`sudo cp #{src}/* #{dst}`
		`sudo /sbin/service solr start`
		puts "Finished in #{(Time.now-start_time)/60} minutes."
	end

#	desc "delete an archive from the RDF reindexing index"
#	task :delete_archive_from_index  => :environment do
#		archive = ENV['archive']
#		if archive == nil || archive.length == 0
#			puts "Pass the archive name to this task"
#		else
#			puts "~~~~~~~~~~~ Deleting archive: #{archive}..."
#			start_time = Time.now
#			reindexed = CollexEngine.new(['reindex_rdf'])
#			reindexed.delete_archive(archive)
#			puts "Finished in #{Time.now-start_time} seconds."
#		end
#	end
#
#	desc "delete an archive from the MARC reindexing index"
#	task :delete_archive_from_marc_index  => :environment do
#		archive = ENV['archive']
#		if archive == nil || archive.length == 0
#			puts "Pass the archive name to this task"
#		else
#			puts "~~~~~~~~~~~ Deleting archive: #{archive}..."
#			start_time = Time.now
#			reindexed = CollexEngine.new(['reindex_marc'])
#			reindexed.delete_archive(archive)
#			puts "Finished in #{Time.now-start_time} seconds."
#		end
#	end

	desc "Look for duplicate objects in rdf folders. (optional param: folder=subfolder under rdf to scan)"
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
			all_objects_raw = `find #{dir}/* -maxdepth 0 -print0 | xargs -0 grep "rdf:about"`	# just do one folder at a time so that grep isn't overwhelmed.
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

	desc "Replace \"merged\" index with all the archive indexes (param: except=archive;archive)"
	task :merge_indexes => :environment do
		archive = ENV['except']
		puts "~~~~~~~~~~~ Merging indexes #{ '(except '+archive+')' if archive != nil}..."
		start_time = Time.now
		CollexEngine.merge_all_reindexed(archive==nil ? [] : archive.split(';'))
		puts "Finished in #{(Time.now-start_time)/60} minutes."
	end

	desc "Merge one archive into the \"resources\" index (param: archive=XXX;YYY)"
	task :merge_archive => :environment do
		archive = ENV['archive']
		if archive == nil
			puts "Usage: call with archive=XXX;YYY"
		else
			puts "~~~~~~~~~~~ Merging archive(s) #{archive} ..."
			archives = archive.split(';')
			start_time = Time.now
			index = CollexEngine.new()
			archive_list = []
			archives.each{|arch|
				index_name = CollexEngine.archive_to_core_name(arch)
				index.delete_archive(arch)
				archive_list.push("archive_#{index_name}")
			}
			index.merge(archive_list)
			puts "Finished in #{(Time.now-start_time)/60} minutes."
		end
	end

	desc "Tag all RDF and MARC in SVN (param: label=XXX)"
	task :tag_rdf_and_marc => :environment do
		version = ENV['label']
		if version == nil || version.length == 0
			puts "Usage: pass label=XXX to tag the current set of RDF and MARC records"
		else
			puts "Tagging version #{version}..."
			system("svn copy -rHEAD -m tag https://subversion.lib.virginia.edu/repos/patacriticism/nines/trunk https://subversion.lib.virginia.edu/repos/patacriticism/nines/tags/#{version}")
		end
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
		return directories.sort()
  end
#	desc "Restart solr"
#	task :restart => :environment do
#		Rake::Task['solr:stop'].invoke
#		Rake::Task['solr:start'].invoke
#	end

end
