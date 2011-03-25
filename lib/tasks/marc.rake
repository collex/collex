# encoding: UTF-8
##########################################################################
# Copyright 2011 Applied Research in Patacriticism and the University of Virginia
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

namespace :marc do
	desc "Read a text file in the form \"=035  \\\\$a(CU-RivES)N72335\" in RDF (param: archive=[bancroft|lilly|estc][;max_records])"
	task :marc_text_to_rdf => :environment do
		require "#{Rails.root}/script/lib/marc_text_reader.rb"
		archive = ENV['archive']
		max_records = nil
		if archive
			arr = archive.split(';')
			archive = arr[0]
			max_records = arr[1].to_i if arr.length > 1
		end
		puts "~~~~~~~~~~~ Creating RDF..."
		start_time = Time.now

		logs = { :progress_log_file => "log/#{archive}_marc_progress.log",
			:error_log_file => "log/#{archive}_marc_error.log",
			:url_log_path => "log/#{archive}_marc_link_data.txt"
		}
		if archive == 'bancroft'
			MarcTextReader.read_folder("#{MARC_PATH}/Bancroft", "#{RDF_PATH}/marc/bancroft", 'bancroft', max_records, logs)
		elsif archive == 'lilly'
			MarcTextReader.read_folder("#{MARC_PATH}/Lilly", "#{RDF_PATH}/marc/lilly", 'lilly', max_records, logs)
		elsif archive == 'estc'
			MarcTextReader.read_folder("#{MARC_PATH}/estc", "#{RDF_PATH}/marc/estc", 'estc', max_records, logs)
		else
			puts "Archive name must be one of bancroft, lilly, or estc"
		end

		finish_line(start_time)
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

	def run_marc_indexer(arc, fed, path, max_records)
		rdf_path = "#{RDF_PATH}/marc"
		args = { :tool => :index,
			:forgiving => false,
			:debug => false,
			:verbose => false,
			:max_records => max_records,
			:archive => arc,
			:progress_log_file => "log/#{arc}_marc_progress.log",
			:error_log_file => "log/#{arc}_marc_error.log",
			:url_log_path => "log/#{arc}_marc_link_data.txt",
#			:solr_url => "#{SOLR_URL}/archive_#{arc}",
			:federation => fed,
			:rdf_path => rdf_path
		}
		if !rdf_path
			CollexEngine.create_core("archive_#{arc}")
		end

		args[:dir] = "#{MARC_PATH}/#{path}"
		MarcIndexer.run(args)
	end

	desc "Reindex all MARC records (optional param: archive=[bancroft|lilly|estc|galeDLB|flBaldwin][;max_records])"
	task :reindex_marc => :environment do
		if CAN_INDEX
			require "#{Rails.root}/script/lib/marc_indexer.rb"
			archive = ENV['archive']
			max_records = nil
			if archive
				arr = archive.split(';')
				archive = arr[0]
				max_records = arr[1] if arr.length > 1
			end
			puts "~~~~~~~~~~~ Reindexing marc records..."
			start_time = Time.now

			if archive == nil || archive == 'bancroft'
				run_marc_indexer('bancroft', 'NINES', 'Bancroft', max_records)
			end

			if archive == nil || archive == 'lilly'
				run_marc_indexer('lilly', 'NINES', 'Lilly', max_records)
			end

			if archive == nil || archive == 'estc'
				run_marc_indexer('estc', nil, 'estc', max_records)
			end

#			if archive == nil || archive == 'galeDLB'
#				arc = 'galeDLB'
#				args[:archive] = arc
#				args[:solr_url] = "#{SOLR_URL}/archive_#{arc}"
#				args[:url_log_path] = "log/#{arc}_link_data.txt"
#				args[:federation] = 'NINES'
#				CollexEngine.create_core("archive_#{arc}")
#				args[:dir] = "#{marc_path}#{arc}"
#				MarcIndexer.run(args)
#			end
#
#			if archive == nil || archive == 'flBaldwin'
#				arc = 'flBaldwin'
#				args[:archive] = arc
#				args[:solr_url] = "#{SOLR_URL}/archive_#{arc}"
#				args[:url_log_path] = "log/#{arc}_link_data.txt"
#				args[:federation] = 'NINES'
#				CollexEngine.create_core("archive_#{arc}")
#				args[:dir] = "#{marc_path}#{arc}"
#				MarcIndexer.run(args)
#			end
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
			if archive == nil
				puts "Usage: Pass in an archive name with archive=XXX; there should be a folder of the same name under #{MARC_PATH}"
			else
				puts "~~~~~~~~~~~ Scanning #{"the first #{max_records} " if max_records != nil}marc records in #{archive}..."
				start_time = Time.now
					args = { :tool => :index,
										:forgiving => true,
										:debug => true,
										:verbose => true,
										:archive => archive,
										:solr_url => "#{SOLR_URL}/archive_#{archive}",
										:url_log_path => "log/shouldnt_be_needed.txt",
										:federation => 'NINES',	# this is calculated for each record
										:dir => "#{MARC_PATH}/#{archive}",
										:max_records => max_records
										}
				MarcIndexer.run(args)

				puts "Finished in #{(Time.now-start_time)/60} minutes."
			end
		end
	end

	desc "Analyze date fields in MARC records (param: archive=[bancroft|lilly|estc][;max_records])"
	task :analyze_marc_dates => :environment do
		if CAN_INDEX
			require 'script/lib/marc_indexer.rb'
			archive = ENV['archive']
			max_records = nil
			if archive
				arr = archive.split(';')
				archive = arr[0]
				max_records = arr[1] if arr.length > 1
			end
			if archive == nil
				puts "Usage: Pass in an archive name with archive=XXX; there should be a folder of the same name under #{MARC_PATH}"
			else
				puts "~~~~~~~~~~~ Scanning #{"the first #{max_records} " if max_records != nil}marc records in #{archive}..."
				start_time = Time.now
				args = { :tool => :index,
					:forgiving => false,
					:debug => true,
#					:verbose => true,
					:dates_only => true,
					:archive => archive,
					:solr_url => "#{SOLR_URL}/archive_#{archive}",
					:url_log_path => "log/shouldnt_be_needed.txt",
					:federation => 'NINES',	# this is calculated for each record
					:dir => "#{MARC_PATH}/#{archive}",
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
			archive = ENV['archive']
			max_records = nil
			if archive
				arr = archive.split(';')
				archive = arr[0]
				max_records = arr[1] if arr.length > 1
			end
			if archive == nil
				puts "Usage: Pass in an archive name with archive=XXX; there should be a folder of the same name under #{MARC_PATH}"
			else
				puts "~~~~~~~~~~~ Scanning for genres in #{archive}..."
				start_time = Time.now
				MarcGenreScanner.run("#{MARC_PATH}/#{archive}", true, max_records)
				puts "Finished in #{(Time.now-start_time)/60} minutes."
			end
		end
	end

end
