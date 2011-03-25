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

require 'script/lib/marc_ext/lib/marc_ext.rb'
require 'marc_ext/record'
class MARC::Record
  include MARCEXT::Record
end

$KCODE = 'UTF8'

class MarcUrlScanner
    
  def self.run( files_to_index_dir, forgiving )
    puts "Scanning for url components..."
    start_time = Time.new ## start the clock

    scanner = MarcUrlScanner.new( forgiving )
    scanner.scan_directory(files_to_index_dir)
    scanner.generate_report()

    end_time = Time.new
    time_lapsed = end_time - start_time
    puts "Scan completed in #{time_lapsed} seconds" 
  end
      
  attr_reader :record_count
  
  def initialize( forgiving )
    @record_count = 0
    @invalid_record_count = 0
    @invalid_title_count = 0
    @forgiving = forgiving
  end
  
  def scan_directory( dir )
    ## put all of the .mrc files in the directory into an array
    marc_files = Dir["#{dir}/*.mrc"].entries

    ## go through all the .mrc files in the files_to_index_dir and pull out the genre information
    marc_files.each do |marc_file|
      scan_file(marc_file)
    end    
  end
  
  def code_string( code )
    "#{code[0]}.#{code[1]}"
  end
  
  def generate_report()
     puts "Scan Summary"
     puts "============"
     puts "#{@invalid_record_count} are missing URL data."
     puts "#{@invalid_title_count} have proper URL data but are missing a title."
     puts "#{@record_count} MARC records scanned."    
  end
  
  def scan_file( marc_file )
    puts "Scanning #{marc_file}..."
    reader = MARC::Reader.new(marc_file, { :forgiving => @forgiving })
    for record in reader
      scan_record( record )  
    end   
  end
  
  def get_subfield( record, code )
    field = record[code[0]]
    if field
      subfield = field[code[1]]
      if subfield
        return subfield
      end
    end
    return nil
  end

  def scan_record( record )
    scan_lilly_record(record)
  end

  def scan_lilly_record( record )
    if record.extract('001').to_s == '' 
      @invalid_record_count = @invalid_record_count + 1
    elsif record.extract('245a').to_s == '' && record.extract('245b').to_s == ''
       @invalid_title_count = @invalid_title_count + 1
       puts record.to_s
    end
     
    @record_count = @record_count + 1
  end
  
  def scan_bancroft_record( record )
    if get_subfield( record, ['950','a'] ).nil? || get_subfield( record, ['950','b'] ).nil?
      @invalid_record_count = @invalid_record_count + 1
    elsif record.extract('245a').to_s == '' && record.extract('245b').to_s == ''
       @invalid_title_count = @invalid_title_count + 1
       puts record.to_s
    end
     
    @record_count = @record_count + 1
  end
  
end

MarcUrlScanner.run('marc/data',true)
