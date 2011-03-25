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

require 'script/lib/marc_ext/lib/marc_ext.rb'
require 'marc_ext/record'
class MARC::Record
  include MARCEXT::Record
end

# # IS THIS ACTUALLY USED ANYWHERE???
$KCODE = 'UTF8'

class MarcExtractor
  
  SEARCH_TARGET = {
    :id => '7310693'
  }
  
  def self.run( files_to_search_dir, output_filename )
    puts "Extracting records..."
    start_time = Time.new ## start the clock

    MarcExtractor.new( files_to_search_dir, output_filename )

    end_time = Time.new
    time_lapsed = end_time - start_time
    puts "Extraction completed in #{time_lapsed} seconds." 
  end
      
  attr_reader :record_count
  
  def initialize(dir, output_filename)
    @writer = MARC::Writer.new(output_filename)
    @record_count = 0

    # put all of the .mrc files in the directory into an array
    marc_files = Dir["#{dir}/*.mrc"].entries

    # go through all the .mrc files 
    marc_files.each do |marc_file|
      search_file(marc_file)
    end
    
    puts "Extracted #{@record_count} records."
    @writer.close()
  end
  
  def search_file( marc_file )
    puts "Searching #{marc_file}..."
    reader = MARC::Reader.new(marc_file, { :forgiving => true })
    reader.each do |record|
      extract_record( record ) if match_record( record ) 
    end   
  end
  
  def match_record( record )
    SEARCH_TARGET[:id] == record.extract('001').to_s
  end
  
  # extract the record into a new MRC file
  def extract_record( record )
    @writer.write(record)
    @record_count = @record_count + 1
  end
  
end

