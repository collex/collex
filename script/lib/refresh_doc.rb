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
#require 'solr'
#require 'cgi'

$KCODE = 'UTF8'

class RefreshDoc
  
  def self.run( args )
    
    if args[:uri].nil?
      puts "ERROR: No uri specified."
      return
    end

    if args[:core].nil?
      puts "ERROR: No core specified."
      return
    end

    puts "Refreshing text for #{args[:uri]} in the archive #{args[:core]}..."
    start_time = Time.new ## start the clock
    
    RefreshDoc.new(args)
   
    end_time = Time.new
    time_lapsed = end_time - start_time
    puts "Indexing completed in #{time_lapsed} seconds" 
  end
  
  def initialize( args )
		verbose = args[:verbose]
		core = CollexEngine.new([args[:core]])
		doc = core.get_object(args[:uri])
		if doc == nil
			puts "Error: Could not find object in the archive."
		else
			url = doc['url']
			fulltext = `curl #{url}`
			doc['text'] = clean_text(fulltext)
			core.add_object(doc)
			report_record(doc) if verbose
		end
  end
  
  def report_record( solr_document )
    puts "Solr Document"
    puts "============="
    solr_document.keys.each do |field|
      puts "#{field}: #{solr_document[field]}"
    end
    puts 
  end

	def remove_bracketed(full_text, left, right)
		start = full_text.index(left)
		while start != nil do
			en = full_text.index(right, start)
			if en == nil
				start = nil
			else
				before = full_text.slice(0, start)
				after = full_text.slice(en + right.length, full_text.length)
				full_text = "#{before}\n#{after}"
				start = full_text.index(left)
			end
		end
		return full_text
	end

	def remove_tag(full_text, tag)
		return remove_bracketed(full_text, "<" + tag, "</" + tag + ">")
	end

	def clean_text(fulltext)
		# If the text contains markup, remove it.
		# We may be passed plain text, or we may be passed html, so any strategy we use needs to work for both.
		# We can assume that if it is plain text, it won't have stuff that looks like tags in it.
		return fulltext if fulltext == nil

		# remove everything between <head>...</head>
		fulltext = remove_tag(fulltext, "head")

		# remove everything between <script>..</script>
		fulltext = remove_tag(fulltext, "script")

		# remove everything between <...>
		fulltext = remove_bracketed(fulltext, "<", ">")

		# Get rid of non-unix line endings
		fulltext = fulltext.gsub("\r", "")

		# Clean up the file a little bit -- there shouldn't be two spaces in a row or blank lines
		fulltext = fulltext.gsub("&nbsp;", " ")
		fulltext = fulltext.gsub("\t", " ")
		fulltext = fulltext.gsub(/ +/, " ")
		fulltext = fulltext.gsub(" \n", "\n")
		fulltext = fulltext.gsub("\n ", "\n")
		fulltext = fulltext.gsub(/\n+/, "\n")

		fulltext = fulltext.gsub("&lt;", "<")
		fulltext = fulltext.gsub("&lt;", "<")
		fulltext = fulltext.gsub("&gt;", ">")
		fulltext = fulltext.gsub("&amp;", "&")

	  return fulltext
		end
 
end