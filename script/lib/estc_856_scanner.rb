##########################################################################
# Copyright 2007 Applied Research in Patacriticism and the University of Virginia
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

#require 'rubygems'
#require 'marc'

$KCODE = 'UTF8'
END_OF_RECORD = 0x1D.chr

class Estc856Scanner
	require 'script/lib/process_gale_objects.rb'
	include ProcessGaleObjects
  def self.run( files_to_index_dir, max_records )
    puts "Scanning for estc 856 fields..."
    start_time = Time.new ## start the clock

    scanner = Estc856Scanner.new( true, max_records )
    scanner.scan_directory(files_to_index_dir)

    end_time = Time.new
    time_lapsed = end_time - start_time
    puts "Scan completed in #{time_lapsed} seconds" 
  end
      
  attr_reader :record_count, :no_genre_found
  
  def initialize( forgiving, max_records )
    @record_count = 0
	@found_count = 0
    @forgiving = forgiving
	@max_records = max_records
	@max_records = @max_records.to_i if @max_records
	@match_uris = {}
	GALE_OBJECTS.each {|arr|
		@match_uris[arr[1]] = true
	}
  end
  
  def scan_directory( dir )
    ## put all of the .mrc files in the directory into an array
    marc_files = Dir["#{dir}/*.mrc"].entries

    ## go through all the .mrc files in the files_to_index_dir and pull out the genre information
    marc_files.each do |marc_file|
      scan_file(marc_file)
    end
  end
  
	def scan_file( marc_file )
		puts "Scanning #{marc_file}..."
		record_this_file = 0
		handle = File.new(marc_file)
		handle.each_line(END_OF_RECORD) do |raw|
			begin
				record = MARC::Reader.decode(raw, :forgiving => true)
				scan_record( record )
				record_this_file = record_this_file + 1
				return if @max_records && record_this_file >= @max_records
			rescue StandardError => e
				# caught exception just keep barrelling along
				# TODO add logging
			end
		end
	end

	# This is for analysis of the estc records to see what their 856 values are.
#	def scan_record(record)
#		uri = "NOT FOUND"
#		match = []
#		record.each { |rec|
#			if rec.tag.include?('035')
#				uri = rec.subfields[0].value.sub("(CU-RivES)", "")
#			end
#			if rec.tag.include?('856')
#				rec.subfields.each {|sf|
#					match.push({ :key => sf.code, :value => sf.value})
#				}
#			end
#		}
#
#		if match.length > 0
#			puts "#{uri}:"
#			match.each {|m|
#				puts "    #{m[:key]} = #{m[:value]}"
#			}
#		end
#	end

	def scan_record( record )
		has_856 = false
		care_about_this_one = false
		uri = ''
		contents = ''
		record.each { |rec|
			if rec.tag.include?('035')
				uri = rec.subfields[0].value.sub("(CU-RivES)", "")
				care_about_this_one = @match_uris["lib://estc/#{uri}"] == true
			elsif rec.tag.include?('856')
				rec.subfields.each {|sf|
					if sf.code == 'u'
						has_856 = true
						contents = sf.value
					end
				}
			end
		}
		@record_count = @record_count + 1
		if care_about_this_one
			@found_count += 1
			if has_856
				puts "#{@found_count}/#{@record_count}. 856: #{uri} = #{contents}"
			else
				puts "#{@found_count}/#{@record_count}. Missing 856 field: #{uri}"
			end
		end
	end
  
end
