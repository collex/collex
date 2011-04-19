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

namespace :solr_index do

	desc "Extract thumbnails for uflBaldwin"
	task :thumbnail_extractor_uflb => :environment do
		# This creates a set of RDF with updated thumbnails for the ufl rdf.
		# A new set of files is placed in ufl_new. If they look good, they can replace the original rdf files.
		# Download the latest marc records from http://ufdc.ufl.edu/data/complete_marc.xml
		# If they aren't there, they can be found somewhere under: http://digital.uflib.ufl.edu/digitalservices/
		
		infile = "/Users/paulrosen/Documents/collex/NINES/complete_marc.xml"
		#outfile = "/Users/paulrosen/Documents/collex/NINES/uflb_thumbnails.csv"
		#out = File.open(outfile, "w")

		START = 1
		LOOKING_FOR_URI = 2
		LOOKING_FOR_THUMB = 3
		state = START
		uri = ""
		thumb = ""
		count = 0
		thumbs = {}
		File.open(infile).each { |line|
			if state == START
				if line =~ /tag="856"/
					state = LOOKING_FOR_URI
				elsif line =~ /tag="992"/
					state = LOOKING_FOR_THUMB
				end
			elsif state == LOOKING_FOR_URI
				if line =~ /code="u"/
					state = START
					first = line.index('>')+1
					last = line.index('<', first)-1
					uri = line[first..last]
				elsif line =~ /<\/datafield>/
					state = START
				end
			elsif state == LOOKING_FOR_THUMB
				if line =~ /code="a"/
					state = START
					first = line.index('>')+1
					last = line.index('<', first)-1
					thumb = line[first..last]
				elsif line =~ /<\/datafield>/
					state = START
				end
			end
			if line =~ /<\/record>/
				if uri.length > 0 || thumb.length > 0
					#out.puts "#{uri}\t#{thumb}"
					arr = uri.split('/')
					id = arr.last()
					thumbs[id] = thumb if thumb.length> 0
					count += 1
					if count % 8000 == 0
						puts ""
					elsif count % 1000 == 0
						print '+'
					elsif count % 100 == 0
						print '.'
					end
					uri = ""
					thumb = ""
				end
			end
		}

		# now thumbs contain a hash of the id (the last part of the uri) and the url of the thumbnail
		# If there is no thumbnail, then the item won't be in the list.
		puts "\nNumber of thumbnails: #{thumbs.length}"
		files = [ "/Users/paulrosen/RubymineProjects/rdf/ufl/dloc/dloc.1.rdf",
				  "/Users/paulrosen/RubymineProjects/rdf/ufl/dloc/dloc_supplement.rdf",
				  "/Users/paulrosen/RubymineProjects/rdf/ufl/Baldwin/baldwin_1.rdf",
				  "/Users/paulrosen/RubymineProjects/rdf/ufl/Baldwin/baldwin_2.rdf",
				  "/Users/paulrosen/RubymineProjects/rdf/ufl/Baldwin/baldwin_3.rdf"
		]
		thumbnail_line = "      <collex:thumbnail rdf:resource=\"$1\"/>"

		files.each { |infile|
			outfile = infile.sub("/ufl/", "/ufl_new/" )
			out = File.open(outfile, "w")
			idd = ""
			File.open(infile).each { |line|
				if line.include?("rdf:about=")
					# the id is everything after the last equal, up to the next double quote
					arr = line.split("=")
					str = arr.last
					arr = str.split('"')
					idd = arr[0]
					if idd.include?('.')
						idd = idd.split('.')[0]
					end
					out.puts(line)
				elsif line.include?("collex:thumbnail")
					if thumbs[idd]
						out.puts(thumbnail_line.sub("$1", thumbs[idd]))
					end
					idd = ''
				elsif line.include?("</uflBaldwin:text>")
					if idd.length != 0
						if thumbs[idd]
							out.puts(thumbnail_line.sub("$1", thumbs[idd]))
						end
						idd = ''
					end
					out.puts(line)
				else
					out.puts(line)
				end
			}
		}
	end
end
