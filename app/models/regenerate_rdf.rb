# ------------------------------------------------------------------------
#     Copyright 2009 Applied Research in Patacriticism and the University of Virginia
# 
#     Licensed under the Apache License, Version 2.0 (the "License");
#     you may not use this file except in compliance with the License.
#     You may obtain a copy of the License at
# 
#         http://www.apache.org/licenses/LICENSE-2.0
# 
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.
# ----------------------------------------------------------------------------

# This is for the case where we have good data in the index, but we don't have the original
# source RDF that created it. This will reverse engineer it. (Used to create the uva_library records.)
class RegenerateRdf
  def initialize
    
  end

	def self.header()
		return '<rdf:RDF xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
			xmlns:role="http://www.loc.gov/loc.terms/relators/"
			xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:dc="http://purl.org/dc/elements/1.1/"
			xmlns:dcterms="http://purl.org/dc/terms/"
			xmlns:collex="http://www.collex.org/schema#"
			xmlns:recreate="http://www.collex.org/recreate_schema#">' + "\n"
	end

	def self.footer()
		return "</rdf:RDF>\n"
	end

	private
	def self.start_file(output_folder, file_prefix, file_number)
		filename = "#{output_folder}/#{file_prefix}_#{file_number}.rdf"
		file = File.new(filename, 'w')
		file << self.header()
		puts "opening #{filename}..."
		return file_number+1, file
	end
	
	def self.stop_file(file)
		file << self.footer()
		file.close()
	end
	
	public
	def self.regenerate_all(hits, output_folder, file_prefix)
		size = 0
		file_number = 1000
		file_number, file = self.start_file(output_folder, file_prefix, file_number)
		hits.each {|hit|
			#puts "generating: #{hit['uri']}..."
			str = self.regenerate_obj(hit)
			file << str
			size += str.length
			if size > 250000
				self.stop_file(file)
				file_number, file = self.start_file(output_folder, file_prefix, file_number)
				size = 0
			end
		}
		self.stop_file(file)
	end

	def self.regenerate_obj(obj)
		main_node = "recreate:collections"
		str = "<#{main_node} rdf:about=\"#{obj['uri']}\">\n"
		obj.each { |key, value_arr|
			if !value_arr.kind_of?(Array)
				value_arr = [ value_arr ]
			end
			value_arr.each_with_index { |val,i|
				val = "#{val}".gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
				case key
				when 'archive'
					str += self.format_item("collex:archive", val)
				when 'title'
					str += self.format_item("dc:title", val)
				when 'text'
					str += self.format_item("collex:text", val)
				when 'date_label'
					# year and date_label are put in at the same time, so we'll look for year here and ignore it when it naturally comes up.
					year = obj['year']
					str += "\t<dc:date><collex:date>\n\t#{self.format_item("rdfs:label", val)}\t#{self.format_item("rdf:value", year[i]) if year[i]}\t</collex:date></dc:date>\n"
				when 'year'
					#nothing here: handled above
	#			when 'url'
	#				str += self.format_item("dc:title", val)
				when 'uri'
					# just ignore the uri: we've used it already
				when 'score'
					# just ignore the score
				when 'type'
					# just ignore the type; it is always 'A'
				when 'batch'
					# just ignore the batch code
				when 'role_AUT'
					str += self.format_item("role:AUT", val)
				when 'role_PBL'
					str += self.format_item("role:PBL", val)
				when 'genre'
					str += self.format_item("collex:genre", val)
				when 'url'
					 str += "\t<rdfs:seeAlso rdf:resource=\"#{val}\"/>\n"
				else
					puts "Unhandled key: #{key}=#{val.to_s}"
				end
			}
		}

#      <rdfs:seeAlso rdf:resource="http://pm.nlx.com/xtf/view?docId=wordsworths_c/wordsworths_c.11.xml;chunk.id=div.el.mary.wordsworth.101"/>
#      <dc:source>The Collected Letters of the Wordsworths. Electronic edition.</dc:source>
#      <dc:source>The Letters of William and Dorothy Wordsworth. Volume 11</dc:source>
#      <role:EDT>Burton, Mary E.</role:EDT>
#      <collex:freeculture>FALSE</collex:freeculture>
#      <dc:date>
#         <collex:date>
#            <rdfs:label>1800's</rdfs:label>
#            <rdf:value>18uu</rdf:value>
#         </collex:date>
#      </dc:date>
#      <dcterms:isPartOf rdf:resource="http://pm.nlx.com/xtf/view?docId=wordsworths_c/wordsworths_c.11.xml"/>
		str += "</#{main_node}>\n"
		return str
	end

	private
	def self.format_item(key, val)
		return "\t<#{key}>#{val}</#{key}>\n"
	end

	def self.format_item_array(key, val)
		str = ""
		val.each { |item|
			str += self.format_item(key, val)
		}
		return str
	end

end
