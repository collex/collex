# encoding: UTF-8
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
$KCODE = 'UTF8'

namespace :solr_index do

	desc "Reindex all user content"
	task :reindex_all_user_content => :environment do
		solr = SearchUserContent.new
		solr.reindex_all()
	end

	def cmd_line(str)
		puts str
		puts `#{str}`
	end

	def create_sh_file(name)
		path = "#{Rails.root}/tmp/#{name}.sh"
		sh = File.open(path, 'w')
		sh.puts("#!/bin/sh\n")
		`chmod +x #{path}`
		return sh
	end

	def delete_file(fname)
		begin
			File.delete(fname)
		rescue
		end
	end

	def get_folders(path, archive)
		folder_file = File.join(path, "sitemap.yml")
		site_map = YAML.load_file(folder_file)
		rdf_folders = site_map['archives']
		all_enum_archives = {}
		rdf_folders.each { |k,f|
			if f.kind_of?(String)
				all_enum_archives[k] = f
			else
				all_enum_archives.merge!(f)
			end
		}
		folders = all_enum_archives[archive]
		if folders == nil
			return { :error => "The archive \"#{archive}\" was not found in #{folder_file}" }
		end
		return { :folders => folders[0].split(';'), :pagesize => folders[1] }
	end

	desc "create complete reindexing task list"
	task :create_reindexing_task_list => :environment do
		solr = CollexEngine.factory_create(false)
		archives = solr.get_all_archives()

		folder_file = File.join(RDF_PATH, "sitemap.yml")
		site_map = YAML.load_file(folder_file)
		rdf_folders = site_map['archives']
#		folder_file = File.join(MARC_PATH, "sitemap.yml")
#		site_map = YAML.load_file(folder_file)
#		marc_folders = site_map['archives']
		sh_all = create_sh_file("batch_all")

		# the archives found need to exactly match the archives in the site maps.
		all_enum_archives = {}
		rdf_folders.each { |k,f|
			all_enum_archives.merge!(f)
		}
		#all_enum_archives.merge!(marc_folders)
		archives.each {|archive|
			if archive.index("exhibit_") != 0 && archive != "ECCO" && all_enum_archives[archive] == nil
				puts "Missing archive #{archive} from the sitemap.yml files"
			end
		}
		all_enum_archives.each {|k,v|
			if !archives.include?(k)
				puts "Archive #{k} in sitemap missing from deployed index"
			end
		}

		sh_clr = create_sh_file("clear_archives")
		core_archives = CollexEngine.get_archive_core_list()
		core_archives.each {|archive|
			sh_clr.puts("curl #{SOLR_URL}/#{archive}/update?stream.body=%3Cdelete%3E%3Cquery%3E*:*%3C/query%3E%3C/delete%3E\n")
			sh_clr.puts("curl #{SOLR_URL}/#{archive}/update?stream.body=%3Ccommit%3E%3C/commit%3E\n")
		}
		sh_clr.close()

		rdf_folders.each { |i, rdfs|
			sh_rdf = create_sh_file("batch#{i+1}")
			rdfs.each {|archive,f|
				sh_rdf.puts("rake \"archive=#{archive}\" solr_index:reindex_and_test_rdf\n")
				sh_all.puts("rake \"archive=#{archive}\" solr_index:reindex_and_test_rdf\n")
			}
			sh_rdf.close()
		}

		sh_ecco = create_sh_file("batch_ecco")
#		marc_folders.each {|archive,folder|
#			sh_marc.puts("rake archive=#{archive} marc:reindex_marc\n")
#			sh_marc.puts("rake archive=#{archive} solr_index:test_archive\n")
#			sh_all.puts("rake archive=#{archive} marc:reindex_marc\n")
#			sh_all.puts("rake archive=#{archive} solr_index:test_archive\n")
#		}

		sh_ecco.puts("rake ecco:index_ecco\n")
		sh_ecco.puts("rake archive=ECCO solr_index:test_archive\n")
		sh_ecco.puts("rake ecco:mark_for_textwright\n")
		sh_all.puts("rake ecco:index_ecco\n")
		sh_all.puts("rake archive=ECCO solr_index:test_archive\n")
		sh_all.puts("rake ecco:mark_for_textwright\n")
		sh_ecco.close()

		sh_all.close()
	end

	def finish_line(start_time)
		duration = Time.now-start_time
		if duration >= 60
			str = "Finished in #{"%.2f" % (duration/60)} minutes."
		else
			str = "Finished in #{"%.2f" % duration} seconds."
		end
		CollexEngine.report_line_if(str)
	end

	def index_archive(msg, archive, type, fromUrl=nil)
		puts "~~~~~~~~~~~ #{msg} \"#{archive}\" [see log/#{archive}_progress.log and log/#{archive}_error.log]"
		start_time = Time.now
		flags = nil
		case type
			when :reindex then flags = "-reindex"
			when :fulltext then flags = "-fulltext"
			when :debug then flags = "-test"
		end
		if flags == nil
			puts "Call with either :reindex, :fulltext, or :debug"
		else
		  if fromUrl != nil
		    flags += " -from #{fromUrl}"
		  end
			folders = get_folders(RDF_PATH, archive)
			if folders[:error]
				puts folders[:error]
			else
			  safe_name = CollexEngine::archive_to_core_name(archive)
			  log_dir = "#{Rails.root}/log"
				delete_file("#{log_dir}/#{safe_name}_progress.log")
				delete_file("#{log_dir}/#{safe_name}_error.log")
				delete_file("#{log_dir}/#{safe_name}_link_data.log")
				delete_file("#{log_dir}/#{safe_name}_duplicates.log")
				
				ENV['index'] = "archive_#{CollexEngine::archive_to_core_name(archive)}"
				Rake::Task['solr_index:clear_reindexing_index'].invoke

				folders[:folders].each {|folder|
					cmd_line("cd #{Rails.root}/lib/tasks/rdf-indexer/target && java -Xmx3584m -jar rdf-indexer.jar -logDir \"#{log_dir}\" -source #{RDF_PATH}/#{folder} -archive \"#{archive}\" #{flags}")
				}
			end
		end
		finish_line(start_time)
	end

	def test_archive(archive)
		puts "~~~~~~~~~~~ testing \"#{archive}\" [see log/#{archive}_*.log]"
		start_time = Time.now
#		do_dups = true
		folders = get_folders(RDF_PATH, archive)
#		if folders[:error]
#			folders = get_folders(MARC_PATH, archive)
#			do_dups = false
#		end
		if folders[:error]
			puts "The archive entry for \"#{archive}\" was not found in any sitemap.yml file."
		else
#			if do_dups
				folders[:folders].each {|folder|
					ENV['folder'] = "#{folder},#{archive}"
					Rake::Task['solr_index:find_duplicate_objects'].invoke
				}
#			end
			ENV['archive'] = archive
			ENV['pageSize'] = folders[:pagesize].to_s
#			Rake::Task['solr_index:scan_for_missed_objects'].invoke
#			ENV['archive'] = archive
#			Rake::Task['solr_index:compare_indexes'].invoke	# list the differences between the objects
#			ENV['archive'] = archive
#			Rake::Task['solr_index:compare_indexes_text'].invoke	# list the differences between the text in the objects
			Rake::Task['solr_index:compare_indexes_java'].invoke
		end
		finish_line(start_time)
	end

	desc "Reindex and test one rdf archive (param: archive=XXX)"
	task :reindex_and_test_rdf => :environment do
		archive = ENV['archive']
		if archive == nil
			puts "Usage: call with archive=XXX"
		else
			index_archive("reindex", archive, :reindex)
			test_archive(archive)
		end
	end

	desc "Reindex and test one marc archive (param: archive=XXX)"
	task :reindex_and_test_marc => :environment do
		start_time = Time.now
		archive = ENV['archive']
		if archive == nil
			puts "Usage: call with archive=XXX"
		else
			ENV['archive'] = archive
			Rake::Task['solr_index:reindex_marc'].invoke
			test_archive(archive)
		end

		finish_line(start_time)
	end

	desc "Reindex documents from the rdf folder to the reindex core (param: archive=XXX,from=URL {opt) )"
	task :reindex_rdf  => :environment do
		archive = ENV['archive']
		fromUrl = ENV['from']
		if archive == nil
			puts "Usage: call with archive=XXX"
		else
		  index_archive("Reindex", archive, :reindex, fromUrl)		
	  end
	end

	desc "Test one archive of any type (param: archive=XXX)"
	task :test_archive => :environment do
		archive = ENV['archive']
		if archive == nil
			puts "Usage: call with archive=XXX"
		else
			test_archive(archive)
		end
	end

	desc "Do the initial indexing of a folder to the archive_* core (param: archive=XXX)"
	task :debug_rdf  => :environment do
		archive = ENV['archive']
		if archive == nil
			puts "Usage: call with archive=archive"
		else
			index_archive("Debug", archive, :debug)
		end
	end

	desc "Do the full indexing of a folder to the archive_* core. This will spider the archive for the full text. (param: archive=XXX)"
	task :index_fulltext_rdf  => :environment do
		archive = ENV['archive']
		if archive == nil
			puts "Usage: call with archive=archive"
		else
			index_archive("Full text", archive, :fulltext)
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
			require "#{Rails.root}/script/lib/refresh_doc.rb"
			RefreshDoc.run({ :uri => p2[1], :verbose => true, :core => p2[0] })
		end
			finish_line(start_time)
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
		finish_line(start_time)
	end

	desc "Creates an RDF with all available information from all objects in the specified archive (params: archive=ARCHIVE[,PATH])"
	task :recreate_rdf_from_index  => :environment do
		# This was created to get the UVA MARC records out of the index when we couldn't recreate the uva MARC records.
		archive = ENV['archive']
		if archive == nil
			puts "Usage: Pass in an archive name with archive=XXX; there should be a folder of the same name under #{RDF_PATH}, or the subfolder can be specified."
		else
			arr = archive.split(',')
			path = arr.length == 1 ? arr[0] : arr[1]
			archive = arr[0]
			puts "~~~~~~~~~~~ Recreating RDF for the #{archive} archive into #{RDF_PATH}/#{path} ..."
			start_time = Time.now
			resources= CollexEngine.new(['resources'])
			all_recs = resources.get_all_objects_in_archive_with_text(archive)
			RegenerateRdf.regenerate_all(all_recs, "#{RDF_PATH}/#{path}", archive)
			finish_line(start_time)
		end
	end

	desc "Get list of objects not reindexed (optional param: use_merged_index=true, archive=XXX)"
	task :scan_for_missed_objects => :environment do
		use_merged_index = ENV['use_merged_index']
		use_merged_index = (use_merged_index != nil && (use_merged_index == "true" || use_merged_index == true))
		archive = ENV['archive']
		puts "~~~~~~~~~~~ Scanning for missed documents #{archive ? "("+archive+" only) " : ""}in #{use_merged_index ? 'merged' : 'archive_*'} index..."
		start_time = Time.now
		CollexEngine.get_list_of_skipped_objects({ :use_merged_index => use_merged_index, :archive => archive, :log => "#{Rails.root}/log/#{CollexEngine.archive_to_core_name(archive)}_skipped.log" })
		finish_line(start_time)
	end

	desc "compare the main index with the reindexed one (parameter: archive=XXX)"
	task :compare_indexes  => :environment do
		archive = ENV['archive']
		if archive == nil
			puts "Usage: Pass in an archive name with archive=XXX; this should match an entry in #{RDF_PATH}/sitemap.yml"
		else
			puts "~~~~~~~~~~~ Comparing documents from the \"resources\" index with the \"archive_#{archive}\" index..."
			start_time = Time.now
			CollexEngine.compare_reindexed_core({ :archive => archive, :log => "#{Rails.root}/log/#{CollexEngine.archive_to_core_name(archive)}_compare.log" })
			finish_line(start_time)
		end
	end
	
	desc "compare the main index with the reindexed one (parameter: archive=XXX mode=compare|compareTxt|<nil> pageSize=xxx)"
  task :compare_indexes_java  => :environment do
    archive = ENV['archive']
	mode = ENV['mode']
	fromUrl = ENV['from']
	pagesize = ENV['pageSize']
	pagesize ||= 500
    flags = "";
    safe_name = CollexEngine::archive_to_core_name(archive)
    log_dir = "#{Rails.root}/log"
    
    # no mode specified = full compare on al fields.
    # delete all log files
    if mode.nil?
      delete_file("#{log_dir}/#{safe_name}_compare.log")
      delete_file("#{log_dir}/#{safe_name}_compare_text.log")  
    else
      # if just txt compare is reauested, ony delete txt log
      if mode == "compareTxt"
        flags = "-include text"  
        delete_file("#{log_dir}/#{safe_name}_compare_text.log")
      end
      
      # if non-txt compare is requested, only delete the compare log
      if mode == "compare"
        flags = "-ignore text"  
        delete_file("#{log_dir}/#{safe_name}_compare.log") 
      end
    end
    
    if fromUrl != nil
      flags += " -from #{fromUrl}"
    end

    # skipped is always deleted
    delete_file("#{log_dir}/#{safe_name}_skipped.log")
      
    # launch the tool
    cmd_line("cd #{Rails.root}/lib/tasks/rdf-indexer/target && java -Xmx3584m -jar rdf-indexer.jar -logDir \"#{log_dir}\" -archive \"#{archive}\" -compare #{flags} -pageSize #{pagesize}")
      
  end

	desc "compare the text in the main index with the reindexed one (parameter: archive=XXX)"
	task :compare_indexes_text  => :environment do
		archive = ENV['archive']
		if archive == nil
			puts "Usage: Pass in an archive name with archive=XXX; this should match an entry in #{RDF_PATH}/sitemap.yml"
		else
			puts "~~~~~~~~~~~ Comparing TEXT from the \"resources\" index with the \"archive_#{archive}\" index..."
			start_time = Time.now
			size = 10
			# if one of the archives with a huge amount of text is requested, only read one record at a time.
			size = 1 if [ 'PQCh-EAF', 'amdeveryday', 'oldBailey' ].include?(archive)
			CollexEngine.compare_reindexed_core_text({ :archive => archive, :size => size,  :log => "#{Rails.root}/log/#{CollexEngine.archive_to_core_name(archive)}_compare_text.log" })
			finish_line(start_time)
		end
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

	desc "clear the reindexing index (param: index=[archive_*])"
	task :clear_reindexing_index  => :environment do
		index = ENV['index']
		if index == nil
			puts "Usage: call with index=XXX"
		else
			puts "~~~~~~~~~~~ Clearing reindexing index #{index}..."
			start_time = Time.now
			reindexed = CollexEngine.new([index])
			reindexed.clear_index()
			finish_line(start_time)
		end
	end

	desc "removes the archive from the resources index (param: archive=XXX;YYY)"
	task :remove_archive  => :environment do
		archives = ENV['archive']
		if archives == nil
			puts "Usage: call with archive=XXX;YYY"
		else
			puts "~~~~~~~~~~~ Remove archive(s) #{archives} from resources..."
			start_time = Time.now
			resources = CollexEngine.new()
			archives = archives.split(';')
			archives.each {|archive|
				resources.delete_archive(archive)
			}
			resources.commit()
			resources.optimize()
			finish_line(start_time)
		end
	end

	desc "recreate the archive index as an exact copy of that archive in the resources (param: archive=XXX)"
	task :copy_resource_to_archive => :environment do
		archive = ENV['archive']
		if archive == nil
			puts "Usage: call with archive=XXX"
		else
			puts "~~~~~~~~~~~ Create archive #{archive} from resources..."
			start_time = Time.now
			folders = get_folders(RDF_PATH, archive)
			if folders[:error]
				puts folders[:error]
			else
				resources = CollexEngine.new()
				dst = CollexEngine.new(["archive_#{archive}"])
				hits = resources.get_all_objects_in_archive_with_text(archive)
				puts "Starting the copy"
				dst.clear_index()
				hits.each_with_index { |hit, i|
					if hit['is_ocr'] == nil
						if hit['text']
							hit['is_ocr'] = true
						else
							hit['is_ocr'] = false
						end
					end
					dst.add_object(hit)
					if i % 100 == 0
						print '.'
					end
				}
				dst.commit()
				finish_line(start_time)
			end
		end

	end

	desc "copy rdf-indexer file for packaging (this cleans and builds it also)"
	task :copy_rdf_indexer => :environment do
		start_time = Time.now
		indexer_path = INDEXER_PATH
		src = "#{indexer_path}/target"
		dst = "#{Rails.root}/lib/tasks/rdf-indexer/target"
		puts "~~~~~~~~~~~ Copying #{src} to #{dst}..."
		begin
	    Dir.mkdir("#{dst}")
		rescue
			# It's ok to fail: it probably means the folder already exists.
		end
		cmd_line("cd #{indexer_path} && mvn -DskipTests=true clean package")
		cmd_line("rm #{dst}/lib/*.jar")
		cmd_line("rm #{dst}/rdf-indexer.jar")
		cmd_line("cp #{src}/lib/*.jar #{dst}/lib/")
		cmd_line("cp #{src}/rdf-indexer.jar #{dst}/rdf-indexer.jar")
		finish_line(start_time)
	end

#	desc "replace resources index with the merged index"
#	task :replace_resources_with_merged => :environment do
#		start_time = Time.now
#		root = Rails.root[0..Rails.root.rindex('/')]
#		solr_data_path = "#{root}solr_1.4/solr/data"
#		src = "#{solr_data_path}/merged/index"
#		dst = "#{solr_data_path}/resources/index"
#		puts "~~~~~~~~~~~ Copying #{src} to #{dst}..."
#		`sudo /sbin/service solr stop`
#		`sudo rm #{dst}/*`
#		`sudo cp #{src}/* #{dst}`
#		`sudo /sbin/service solr start`
#		puts "Finished in #{(Time.now-start_time)/60} minutes."
#	end

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

	desc "Look for duplicate objects in rdf folders (param: folder=subfolder_under_rdf,archive)"
	task :find_duplicate_objects => :environment do
		folder = ENV['folder']
		arr = folder.split(',') if folder
		if arr == nil || arr.length != 2
			puts "Usage: call with folder=folder,archive"
		else
			folder = arr[0]
			archive = arr[1]
			puts "~~~~~~~~~~~ Searching for duplicates in \"#{RDF_PATH}/#{folder}\" ..."
			start_time = Time.now
			puts "creating folder list..."
			directories = get_folder_tree("#{RDF_PATH}/#{folder}", [])

			directories.each{|dir|
				CollexEngine.set_report_file("#{Rails.root}/log/#{CollexEngine.archive_to_core_name(archive)}_duplicates.log")
				puts "scanning #{dir} ..."
				#tim = Time.now
				#all_objects_raw = `grep "rdf:about" #{dir}/*`	# just do one folder at a time so that grep isn't overwhelmed.
				#all_objects_raw = `cd #{dir} && ls * | xargs grep "rdf:about"`	# just do one folder at a time so that grep isn't overwhelmed.
				all_objects_raw = `find #{dir}/* -maxdepth 0 -print0 | xargs -0 grep "rdf:about"`	# just do one folder at a time so that grep isn't overwhelmed.
				all_objects_raw = all_objects_raw.split("\n")
				#puts "finished grep in #{Time.now-tim} seconds..."
				all_objects = {}
				all_objects_raw.each { | obj|
					arr = obj.split(':', 2)
					arr1 = obj.split('rdf:about="', 2)
					arr2 = arr1[1].split('"')
					if all_objects[arr2[0]] == nil
						all_objects[arr2[0]] = arr[0]
					else
						 CollexEngine.report_line("Duplicate: #{arr2[0]} in #{all_objects[arr2[0]]} and #{arr[0]}")
					end
					#count += 1
					#puts "Number scanned: #{count}" if count % 1000 == 0

				}
			}
			finish_line(start_time)
		end
	end

#	desc "Replace \"merged\" index with all the archive indexes (param: except=archive;archive)"
#	task :merge_indexes => :environment do
#		archive = ENV['except']
#		puts "~~~~~~~~~~~ Merging indexes #{ '(except '+archive+')' if archive != nil}..."
#		start_time = Time.now
#		CollexEngine.merge_all_reindexed(archive==nil ? [] : archive.split(';'))
#		puts "Finished in #{(Time.now-start_time)/60} minutes."
#	end

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
			finish_line(start_time)
		end
	end

	desc "Tag all RDF, MARC, and ECCO in SVN (param: label=XXX)"
	task :tag_rdf_marc_and_ecco => :environment do
		version = ENV['label']
		if version == nil || version.length == 0
			puts "Usage: pass label=XXX to tag the current set of RDF, MARC, and ECCO records"
		else
			puts "Tagging version #{version}..."
			system("svn copy -rHEAD -m tag #{SVN_RDF}/trunk #{SVN_RDF}/tags/#{version}")
		end
	end

	def get_folder_tree(starting_dir, directories)
		#define a recursive function that will traverse the directory tree
		# unfortunately, it looks like, at least for OS X and stuff that is returned from SVN, that file? and directory? don't work, so we have some workarounds
		begin
			has_file = false
			Dir.foreach(starting_dir) { |name|
				if !File.file?(name) && name[0] != 46 && name != 'nbproject' && name.index('.rdf') == nil && name.index('.xml') == nil && name.index('.txt') == nil && name[0] != '.'
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

	def safe_mkdir(folder)
		begin
	    Dir.mkdir(folder)
		rescue
			# It's ok to fail: it probably means the folder already exists.
		end
	end

	def safe_mkpath(folder)
		# this makes all the folders in the hierarchy
		arr = folder.split('/')
		path = ""
		arr.each { |level|
			path += "/#{level}"
			safe_mkdir(path)
		}
	end

	desc "Get all the text from a particular archive and dump it in a series of text files"
	task :get_text_from_archive => :environment do
		archive = ENV['archive']
		if archive == nil || archive.length == 0
			puts "Usage: pass archive=XXX"
		else
			folders = get_folders(RDF_PATH, archive)
			if folders[:error]
				puts "The archive entry for \"#{archive}\" was not found in any sitemap.yml file."
			else
				page_size = folders[:pagesize].to_i
				arr = RDF_PATH.split('/')
				arr.pop()
				arr.push('fulltext')
				base_path = arr.join('/')
				folder = "#{base_path}/#{CollexEngine.archive_to_core_name(archive)}"
				puts "Dumping all text from archive #{archive} to #{folder}, page=#{page_size}..."
				safe_mkpath(folder)
				# TODO-PER: first remove all existing files from that folder
				index = CollexEngine.new()
				index.enumerate_all_recs_in_archive(archive, true, page_size) { |hit|
					if hit['text'] && hit['text'].length > 0
						fname = hit['uri'].gsub('/', 'SL').gsub(':', 'CL').gsub('?', 'QU').gsub('=', 'EQ').gsub('&', 'AMP')
						File.open("#{folder}/#{fname}.txt", 'w') {|f| f.write(hit['text'].join("\n")) }
					end
				}
			end
		end

	end
end
