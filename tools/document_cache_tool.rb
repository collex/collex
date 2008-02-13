#!/usr/bin/env ruby
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

require 'optparse'
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")

def parse_command_line( command_line_args )
  status = true
  action = nil
  
  opts = OptionParser.new do |opts|  
        
    opts.on("-f", "--fill", "Fill the document cache based on existing interpretations table.") do |d|
      action = :fill
    end

    opts.on("-c", "--clear", "Clear the document cache.") do |d|
      action = :clear
    end

    ## Display help message 
    opts.on_tail("-h","--help", "Show this usage statement.") do |h|
      puts opts
      status = false
    end
  end

  begin
    opts.parse!(command_line_args)
  rescue Exception => e
    puts e, "", opts
    status = false
  end
  
  (status) ? action : nil 
end

def clear_document_cache()
  puts "Clearing the document cache..."  
  CachedDocument.destroy_all
  CachedAgent.destroy_all
  CachedDate.destroy_all
end

# Update the document cache based on the existing interpretations.
def fill_document_cache()
  puts "Filling the document cache..."
  interpretations = Interpretation.find(:all)     
  interpretations.each do |interpretation|
    cached_document = CachedDocument.create_cache_document(interpretation.object_uri)
    interpretation.tags.each { |tag| cached_document.tags << tag }
    cached_document.save!
  end
end

# Run
case parse_command_line(ARGV)
  when :clear then clear_document_cache()
  when :fill then fill_document_cache()
end
