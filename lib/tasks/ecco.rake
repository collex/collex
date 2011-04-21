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

namespace :ecco do
	def writelog(file, str)
		open(file, 'a') { |f|
			f.puts str
		}
	end

	def process_ecco_spreadsheets
		src = CollexEngine.new(["archive_estc"])
		dst = CollexEngine.new(["archive_ECCO"])
		total_recs = 0
		total_added = 0
		total_already_found = 0
		total_cant_find = 0
		Dir["#{MARC_PATH}/ecco/*.csv"].each {|f|
			File.open(f, 'r') { |f2|
				text = f2.read
				lines = text.split("\n")
				lines.each {|line|
					total_recs += 1
					line = line.gsub('"', '')
					rec = line.split(',', 2)
					# remove zeroes from between the letter and the non-zero part of the number
					reg_ex = /(.)0*(.+)/.match(rec[0])
					estc_id = reg_ex[1] + reg_ex[2]
					estc_uri = "lib://estc/#{estc_id}"
					obj = src.get_object(estc_uri, true)
					if obj == nil
						writelog("#{Rails.root}/log/ecco_error.log", "Can't find object: #{estc_uri}")
						total_cant_find += 1
					else
						arr = rec[1].split('bookId=')
						if arr.length == 1
							writelog("#{Rails.root}/log/ecco_error.log", "Unusual URL encountered: #{rec[1]}")
						else
							arr2 = arr[1].split('&')
							obj['archive'] = "ECCO"
							obj['url'] = [ rec[1] ]
							ecco_id = "lib://ECCO/#{arr2[0]}"
							obj['uri'] = ecco_id
							writelog("#{Rails.root}/log/ecco_error.log", "No year_sort: #{estc_uri} #{obj['uri']}") if obj['year_sort'] == nil
							writelog("#{Rails.root}/log/ecco_error.log", "No title_sort: #{estc_uri} #{obj['uri']}") if obj['title_sort'] == nil
							dst.add_object(obj, nil)
							total_added += 1
							#puts "estc: #{estc_id} ecco: #{ecco_id}"
						end
					end
					CollexEngine.report_line("Total: #{total_recs} Added: #{total_added} Found: #{total_already_found} Can't find: #{total_cant_find}") if total_recs % 500 == 0
				}
			}
		}
		CollexEngine.report_line("Finished: Total: #{total_recs} Added: #{total_added} Found: #{total_already_found} Can't find: #{total_cant_find}")
	end

	def process_ecco_fulltext()
		require "#{Rails.root}/script/lib/process_gale_objects.rb"
		include ProcessGaleObjects
		src = CollexEngine.new(["archive_estc"])
		dst = CollexEngine.new(["archive_ECCO"])
		count = 0
		GALE_OBJECTS.each {|arr|
			filename = arr[0]
			estc_uri = arr[1]
			url = arr[3]
			text = ''
			File.open("#{ECCO_PATH}/#{filename}.txt", "r") { |f|
				text = f.read
			}
			obj = src.get_object(estc_uri, true)
			if obj == nil
				writelog("#{Rails.root}/log/ecco_error.log", "Can't find object: #{estc_uri}")
			else
				obj['text'] = text
				obj['has_full_text'] = true
				obj['freeculture'] = false
				obj['source'] = "Full text provided by the Text Creation Partnership."
				obj['archive'] = "ECCO"
				obj['url'] = [ url ]
				arr = url.split('bookId=')
				if arr.length == 1
					writelog("#{Rails.root}/log/ecco_error.log", "Unusual URL encountered: #{url}")
				else
					arr2 = arr[1].split('&')
					obj['uri'] = "lib://ECCO/#{arr2[0]}"
					writelog("#{Rails.root}/log/ecco_error.log", "No year_sort: #{estc_uri} #{obj['uri']}") if obj['year_sort'] == nil
					writelog("#{Rails.root}/log/ecco_error.log", "No title_sort: #{estc_uri} #{obj['uri']}") if obj['title_sort'] == nil
					dst.add_object(obj, nil)
				end
			end
			count += 1
			CollexEngine.report_line("Processed: #{count}") if count % 500 == 0
		}
	end

	desc "Completely index ecco docs, using estc records."
	task :index_ecco => :environment do
		start_time = Time.now
		CollexEngine.create_core("archive_ECCO")
		dst = CollexEngine.new(["archive_ECCO"])
		dst.start_reindex()
		CollexEngine.set_report_file("#{Rails.root}/log/ecco_error.log")	# just setting this first to delete it if it exists.
		CollexEngine.set_report_file("#{Rails.root}/log/ecco_progress.log")
		CollexEngine.report_line("Processing spreadsheets...")
		process_ecco_spreadsheets()
		CollexEngine.report_line("Processing fulltext...")
		process_ecco_fulltext()
		CollexEngine.report_line("Finished in #{(Time.now-start_time)/60} minutes.")
		dst.commit()
		dst.optimize()
		CollexEngine.report_line("Optimized in #{(Time.now-start_time)/60} minutes.")
	end

	desc "Just add full text to ecco docs, using estc records."
	task :index_ecco_text_only => :environment do
		start_time = Time.now
#		CollexEngine.create_core("archive_ECCO")
#		dst = CollexEngine.new(["archive_ECCO"])
#		dst.start_reindex()
		CollexEngine.set_report_file("#{Rails.root}/log/ecco_error.log")	# just setting this first to delete it if it exists.
		CollexEngine.set_report_file("#{Rails.root}/log/ecco_progress.log")
#		CollexEngine.report_line("Processing spreadsheets...")
#		process_ecco_spreadsheets()
		CollexEngine.report_line("Processing fulltext...")
		process_ecco_fulltext()
		CollexEngine.report_line("Finished in #{(Time.now-start_time)/60} minutes.")
		dst.commit()
		dst.optimize()
		CollexEngine.report_line("Optimized in #{(Time.now-start_time)/60} minutes.")
	end
#	desc "Create the Gale objects from ESTC"
#	task :process_gale_objects => :environment do
#		require 'script/lib/process_gale_objects.rb'
#		include ProcessGaleObjects
#		CollexEngine.create_core("archive_ECCO")
#		src = CollexEngine.new(["archive_estc"])
#		puts "Number of objects in estc: #{src.num_docs()}"
#		dst = CollexEngine.new(["archive_ECCO"])
#		dst.start_reindex()
#		path = "../ecco/"
#		count = 0
#		GALE_OBJECTS.each {|arr|
#			filename = arr[0]
#			estc_uri = arr[1]
#			url = arr[3]
#			text = ''
#			File.open("#{path}#{filename}.txt", "r") { |f|
#				text = f.read
#			}
#			obj = src.get_object(estc_uri)
#			if obj == nil
#				puts "Can't find object: #{estc_uri}"
#			else
#				obj['text'] = text
#				obj['has_full_text'] = true
#				obj['archive'] = "ECCO"
#				obj['url'] = [ url ]
#				arr = url.split('bookId=')
#				if arr.length == 1
#					puts "Unusual URL encountered: #{url}"
#				else
#					arr2 = arr[1].split('&')
#					obj['uri'] = "lib://ECCO/#{arr2[0]}"
#					dst.add_object(obj, nil)
#				end
#			end
#			count += 1
#			puts "Processed: #{count}" if count % 100 == 0
#		}
#		dst.commit()
#		dst.optimize()
#	end

	desc "Test that all ECCO objects have a 856 field (param: max_recs=XXX)"
	task :test_ecco_856 => :environment do
		if CAN_INDEX
			max_records = ENV['max_recs']

			puts "~~~~~~~~~~~ Scanning for 856 fields in estc..."
			start_time = Time.now
			require '#{Rails.root}/script/lib/estc_856_scanner.rb'
			Estc856Scanner.run("#{MARC_PATH}/estc", max_records)
			puts "Finished in #{(Time.now-start_time)/60} minutes."
		end
	end

	desc "Mark texts for textwright"
	task :mark_for_textwright => :environment do
		texts = ['0109300900',  '0111901400',  '0135203600',  '0143001400',  '0158201300' ]

		src = CollexEngine.new(["resources"])
		dst = CollexEngine.new(["archive_ECCO"])
		texts.each { |text|
			uri = "lib://ECCO/#{text}"
			obj = src.get_object_with_text(uri)
			if obj
				obj['typewright'] = true
				dst.add_object(obj)
				puts "Added: #{text}"
			else
				puts "Not found: #{text}"
			end
		}
		dst.commit()

	end
	
	desc "Un-mark ALL texts for textwright"
  task :unmark_for_textwright => :environment do
    texts = [ '0042000900', '0077500200', '0109300900', '0111901400', '0135203600', '0143001400', '0158201300', '0227700700', '0239200301', '0247600500',
          '0290802600', '0308400200', '0322000100', '0330900300', '0340001700', '0353100200', '0365800102', '0387301300', '0392200102', '0398600300',
          '0408200204', '0484000100', '0495500102', '0537000600', '0583400201', '0587600101', '0616600300', '0637500600', '0676200500', '0822400100',
          '0840500700', '0841500302', '0874003200', '0885500301', '0922300400', '1088700100', '1095301400', '1145500600', '1248102500', '1257000400',
          '1276900100', '1292703600', '1299705900', '1300001800', '1405400600', '1474000100', '1487400200', '1496402100', '1500500900', '1519400101',
          '1563300700', '1668600800', '1775900400' ]

    src = CollexEngine.new(["resources"])
    dst = CollexEngine.new(["archive_ECCO"])
    texts.each { |text|
      uri = "lib://ECCO/#{text}"
      obj = src.get_object_with_text(uri)
      if obj
        obj['typewright'] = false
        dst.add_object(obj)
        puts "Added: #{text}"
      else
        puts "Not found: #{text}"
      end
    }
    dst.commit()

  end
end
