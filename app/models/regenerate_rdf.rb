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
	def self.safe_mkdir(folder)
		folders = folder.split('/')
		folder = ''
		folders.each {|sub|
			folder += '/' + sub
			begin
				Dir.mkdir(folder)
			rescue
				# It's ok to fail: it probably means the folder already exists.
			end
		}
	end

	def self.regenerate_all(hits, output_folder, file_prefix, target_size = 250000)
		self.safe_mkdir(output_folder)
		size = 0
		file_number = 1000
		file_number, file = self.start_file(output_folder, file_prefix, file_number)
		hits.each {|hit|
			#puts "generating: #{hit['uri']}..."
			str = self.regenerate_obj(hit)
			file << str
			size += str.length
			if size > target_size
				self.stop_file(file)
				file_number, file = self.start_file(output_folder, file_prefix, file_number)
				size = 0
			end
		}
		self.stop_file(file)
	end

	def self.regenerate_obj(obj)
		main_node = "recreate:collections"
		uri = obj['uri']
		uri = obj[:uri] if uri == nil
		str = "<#{main_node} rdf:about=\"#{uri}\">\n"
		items = self.format_items(obj)
		# list them in the same order each time
		keys = [ 'archive', 'freeculture', 'has_full_text', 'is_ocr', 'genre', 'text', 'title', 'role_AUT', 'federation', 'role_PBL', 'date_label', 'url', 'source' ]
		keys.each {|key|
			if items[key]
				items[key].each {|it|
					str += it
				}
			end
		}

		str += "</#{main_node}>\n"
		return str
	end

	def self.gen_item(hash, key, val)
		hash[key.to_s] = [] if hash[key.to_s] == nil
		hash[key.to_s].push(val)
	end

	def self.format_items(obj)
		ret = {}
	  obj.each { |key, value_arr|
		  if !value_arr.kind_of?(Array)
			  value_arr = [ value_arr ]
		  end
		  value_arr.each_with_index { |val,i|
			  val = "#{val}".gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
			  case key.to_s
			  when 'archive'
				  self.gen_item(ret, key, self.format_item("collex:archive", val))
			  when 'title'
				  self.gen_item(ret, key, self.format_item("dc:title", val))
			  when 'text'
				 self.gen_item(ret, key, self.format_item("collex:text", val))
			  when 'date_label'
				  # year and date_label are put in at the same time, so we'll look for year here and ignore it when it naturally comes up.
				  year = obj['year']
				  year = obj[:year] if year == nil
				  year = obj['date_label'] if year == nil
				  year = obj[:date_label] if year == nil
				  self.gen_item(ret, key, "\t<dc:date><collex:date>\n\t#{self.format_item("rdfs:label", val)}\t#{self.format_item("rdf:value", year[i]) if year[i]}\t</collex:date></dc:date>\n") if year != nil
			  when 'year'
				  #nothing here: handled above
			  when 'uri'
				  # just ignore the uri: we've used it already
			  when 'score'
				  # just ignore the score
			  when 'type'
				  # just ignore the type; it is always 'A'
			  when 'batch'
				  # just ignore the batch code
			  when 'agent'
				  # just ignore the batch code
			  when 'title_sort'
				  # just ignore this -- it will be recreated
			  when 'author_sort'
				  # just ignore this -- it will be recreated
			  when 'year_sort'
				  # just ignore this -- it will be recreated
			  when 'role_AUT'
				  self.gen_item(ret, key, self.format_item("role:AUT", val))
			  when 'role_PBL'
				  self.gen_item(ret, key, self.format_item("role:PBL", val))
			  when 'genre'
				  self.gen_item(ret, key, self.format_item("collex:genre", val))
			  when 'url'
				   self.gen_item(ret, key, "\t<rdfs:seeAlso rdf:resource=\"#{val}\"/>\n")
			  when 'federation'
				  self.gen_item(ret, key, self.format_item("collex:federation", val))
			  when 'is_ocr'
				  val = 'false' if val == 'F'
				  val = 'true' if val == 'T'
				  self.gen_item(ret, key, self.format_item("collex:ocr", val))
			  when 'has_full_text'
				  val = 'false' if val == 'F'
				  val = 'true' if val == 'T'
				  self.gen_item(ret, key, self.format_item("collex:fulltext", val))
			  when 'freeculture'
				  val = 'false' if val == 'F'
				  val = 'true' if val == 'T'
				  self.gen_item(ret, key, self.format_item("collex:freeculture", val))
			  when 'source'
				  self.gen_item(ret, key, self.format_item("dc:source", val))
			  else
				  puts "Unhandled key: #{key}=#{val.to_s}"
			  end
		  }
	  }
	return ret
  end

	private
	def self.format_item(key, val)
		str = "#{val}"
		if !str.valid_encoding?
			converter = Iconv.new('UTF-8','CP1252')
			begin
				puts "converting..."
				str = converter.iconv(str)
			rescue
				puts "Invalid: #{key}"
				str.each_byte { |b|
					bytes += "#{b} "
				}
				puts bytes
			end
		end

		return "\t<#{key}>#{str}</#{key}>\n"
	end

	def self.format_item_array(key, val)
		str = ""
		val.each { |item|
			str += self.format_item(key, val)
		}
		return str
	end

end
