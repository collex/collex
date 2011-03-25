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
require 'script/lib/nines_mapping.rb'

# # IS THIS ACTUALLY USED ANYWHERE???
$KCODE = 'UTF8'
END_OF_RECORD = 0x1D.chr

class MarcGenreScanner
  
  include NinesMapping
  
  def self.run( files_to_index_dir, forgiving, max_records )
    puts "Scanning for genre keywords..."
    start_time = Time.new ## start the clock

    scanner = MarcGenreScanner.new( forgiving, max_records )
    scanner.scan_directory(files_to_index_dir)
    scanner.generate_report()

    end_time = Time.new
    time_lapsed = end_time - start_time
    puts "Scan completed in #{time_lapsed} seconds" 
  end
      
  attr_reader :record_count, :no_genre_found
  
  MAPPINGS = (GENRE_MAPPING.values + GEOGRAPHIC_MAPPING.values + FORMAT_MAPPING.values).flatten

  def initialize( forgiving, max_records )
    @field_data = {}
    @record_count = 0
    @no_genre_found = 0
    @mapping_found = 0
    @mapped_records_count = 0
    @forgiving = forgiving
	@max_records = max_records
	@max_records = @max_records.to_i if @max_records
  end
  
  def scan_directory( dir )
    ## put all of the .mrc files in the directory into an array
    marc_files = Dir["#{dir}/*.mrc"].entries

    ## go through all the .mrc files in the files_to_index_dir and pull out the genre information
    marc_files.each do |marc_file|
      scan_file(marc_file)
    end
    
    # sort the field data
    @sorted_field_data = @field_data.values.sort { |a,b| a[:count] <=> b[:count] }.reverse  
  end
  
  def code_string( code )
    "#{code[0]}.#{code[1]}"
  end
  
  def generate_report()
    code_list = ""
    SCAN_LIST.each do |code|
      code_list << " " << code_string( code )
    end
    puts
    puts "Scanned for the following MARC record codes: "
    puts code_list
    
    puts
    puts "Scan Summary"
    puts "============"
    puts "#{@mapping_found} keywords were found in the NINES mapping."
    puts "#{@mapped_records_count} MARC records were mapped to NINES genres."
    puts "#{@no_genre_found} MARC records had no data at the specified record codes."
    puts "#{@record_count} MARC records scanned."   
    puts
    puts "Scan Results"
    puts "============"
    puts "* indicates that this keyword was found in the NINES mapping."
    puts "(n) the number of occurrences of this keyword discovered in the MARC data."
    puts 
    @sorted_field_data.each do |data|
      star = data[:mapping] ? "*" : ""
      puts "#{data[:code]} #{data[:field_name]} (#{data[:count]})#{star}"
    end     
    
  end
  
#  def scan_file( marc_file )
#    puts "Scanning #{marc_file}..."
#    reader = MARC::ForgivingReader.new(marc_file) #, { :forgiving => @forgiving })
#    for record in reader
#	   scan_record( record )
#    end
#  end

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
    found = false
    mapped = false
    SCAN_LIST.each do |genre_field|
      field = record[genre_field[0]]
      if field
        subfield = field[genre_field[1]]
        if subfield
          mapped = true if store_field( subfield, code_string(genre_field) ) == true
          found = true
        end
      end
    end
    @record_count = @record_count + 1
    @no_genre_found = @no_genre_found + 1 if not found
    @mapped_records_count = @mapped_records_count + 1 if mapped
  end
  
  def store_field( field_name, code )
    normalized_field_name = normalize_field_name( field_name )    
    data = @field_data[normalized_field_name]
    mapping = false
    
    if data
      data[:count] = @field_data[normalized_field_name][:count] + 1       
      data[:code] << " " << code unless data[:code].include?(code)
      mapping = true if data[:mapping]
    else
      mapping = MAPPINGS.include? normalized_field_name
      @mapping_found = @mapping_found + 1 if mapping
      @field_data[normalized_field_name] = { :field_name => normalized_field_name, :count => 1, :code => code, :mapping => mapping }
    end
    
    mapping
  end
  
  def normalize_field_name( value )
    normed = value.downcase
    if normed[value.size-1] == 46 # remove '.'
      normed = normed[0..-2]
    end
    normed
  end

end
