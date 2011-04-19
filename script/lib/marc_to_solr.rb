# ------------------------------------------------------------------------
#     Copyright 2011 Applied Research in Patacriticism and the University of Virginia
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

require "#{Rails.root}/script/lib/nines_mapping.rb"
require "#{Rails.root}/script/lib/title_code_exceptions.rb"
require "#{Rails.root}/script/lib/parse_date.rb"

class MarcToSolr
	def self.convert(rec, archive, year_ignore)
		hit = { :archive => archive, :has_full_text => 'F', :is_ocr => 'F', :freeculture => 'F' }
		hit[:genre] = self.parse_genre(rec)
		hit[:role_AUT] = self.parse_author(rec)
		hit[:author_sort] = hit[:role_AUT][0] if hit[:role_AUT].length
		pub = self.parse_publisher(rec)
		hit[:role_PBL] = pub if pub.length > 0
		text = self.parse_text(rec)
		hit[:text] = text if text

		#TODO-PER:debug
#		fld = self.first_field(rec,'035','a')
#		if fld.include?('R35432')
#			puts fld
#		end

		years = ParseDate.extract_year(self.all_field(rec,'260','c'), year_ignore)
		hit[:date_label] = ParseDate.reconstruct_date_label(years[:years]) #years[:date_label] 
		hit[:year] =  years[:years]
		hit[:year_sort] = years[:year_sort]

		case archive
		when 'bancroft' then
			hit[:federation] = 'NINES'
			hit[:title] = self.bancroft_title(rec).chomp('.')
			self.must_exist(rec,'950','a')
			self.must_exist(rec,'950','b')
			self.must_exist(rec,'001',' ')
			hit[:url] = "http://oskicat.berkeley.edu/search~S1/?searchtype=c&searcharg=#{CGI.escape(self.first_field(rec,'950','a')+self.first_field(rec,'950','b'))}&searchscope=1"
			hit[:uri] = "lib://bancroft/#{self.first_field(rec,'001',' ')}"
		when 'lilly' then
			hit[:federation] = 'NINES'
			hit[:title] = self.parse_title(rec).chomp('.')
			self.must_exist(rec,'001',' ')
			hit[:url] = "http://www.iucat.iu.edu/uhtbin/cgisirsi/x/0/0/5?library=ALL&searchdata1=^C#{self.first_field(rec,'001',' ')}"
			hit[:uri] = "lib://lilly/#{self.first_field(rec,'001',' ')}"
		when 'estc' then
			hit[:title] = self.parse_title(rec).chomp('.')
			uri = self.estc_uri(rec)
			if uri == nil || uri.length == 0
				MarcTextReader.log_error("No uri found for: #{self.first_field(rec,'001',' ')}")
				return nil
			end
			hit[:url] = "http://estc.bl.uk/" + uri
			hit[:uri] = "lib://estc/" + uri
			hit[:federation] = self.estc_federation(years[:years])
			if hit[:federation] == nil
				MarcTextReader.log_error("No federation selected for: #{hit[:uri]}: \"#{self.combined_field(rec, '260', 'c')}\" [#{years[:years].join(';')}]")
				return nil
			end
		end
		hit[:title_sort] = hit[:title][0] if hit[:title].length > 0

		return hit
	end

	private
	def self.estc_federation(years)
		nines = false
		eighteen = false
		years.each { |year|
			y = year.to_i
			eighteen = true if y > 1660 && y < 1820
			nines = true if y > 1780 && y < 1930
		}
		if nines && eighteen
			return [ "NINES", "18thConnect" ]
		elsif nines && !eighteen
			return "NINES"
		elsif !nines && eighteen
			return "18thConnect"
		end
		return nil

	end

	def self.parse_text(rec)
		list = []
		#puts "---- #{self.first_field(rec, '001', ' ')}"
		# go through all the genre related fields and index that text for searching
		NinesMapping::SCAN_LIST.each do |code|
			subfield = self.all_field(rec, code[0], code[1])
			#puts "    #{code[0]}#{code[1]}: #{subfield}"
			list += subfield if subfield && subfield.length > 0
		end

		# get rid of dups and turn it into a string
		list.uniq!
		s = list.join(' ')

		# get rid of extra spaces
		s = s.strip()
		s = s.gsub(/ +/, ' ')

		# Return nil if there isn't full text.
		return s.length > 0 ? s : nil
	end

	def self.parse_publisher(rec)
		# 260$b is publisher
		publishers = self.combined_field(rec,'260','b')
		publishers = publishers.sub(/[,;:]$/,"")
		return publishers.strip()
	end

	def self.must_exist(rec,key,subkey)
		val = self.first_field(rec,key,subkey)
		if val.length == 0
			MarcTextReader.log_error("Can't find field #{key}#{subkey} in record #{self.first_field(rec,'001',' ')}.")
		end
	end

	def self.combined_field(rec,key,subkey)
		if rec[key] && rec[key][subkey]
			return rec[key][subkey].join(' ').strip
		else
			return ""
		end
	end

	def self.all_field(rec,key,subkey)
		if rec[key] && rec[key][subkey]
			return rec[key][subkey]
		else
			return []
		end
	end

	def self.first_field(rec,key,subkey)
		if rec[key] && rec[key][subkey] && rec[key][subkey].length > 0
			return rec[key][subkey][0]
		else
			return ""
		end
	end

	def self.parse_author(rec)
		authors = []
		NinesMapping::AUTHOR_MARC_CODES.each { |code|
			author = self.combined_field(rec, code[0], code[1])
			authors.push(author.sub(/[,;:]$/,"")) if author && author.length > 0 && authors.include?(author) == false
		}
		return authors
	end

	def self.normalize_genre_field_value( value )
		return nil if value.nil?
		normal = value.downcase
		if normal[normal.size-1] == '.' # .
			normal = normal[0..-2]
		end
		return normal
	end

	def self.genre_mapper(field)
	  genres = []
	  return genres if field == nil || field.length == 0
	  genre = normalize_genre_field_value(field)
	  return genres if genre == nil || genre.length == 0

	  [ NinesMapping::GENRE_MAPPING, NinesMapping::GEOGRAPHIC_MAPPING, NinesMapping::FORMAT_MAPPING ].each do |mapping|
		mapping.keys.each do |key|
		  matching_values = mapping[key]
		  matching_values.each {|val|
			  if genre.include? val
				genres << key unless genres.include? key
			  end
		  }
		end
	  end

	  return genres
	end

	def self.parse_genre(rec)
		nines_genres = ['Citation']
		NinesMapping::SCAN_LIST.each do |genre_field|
			subfield = self.combined_field(rec, genre_field[0], genre_field[1])
			genres = genre_mapper( subfield )
			genres.each do |genre|
				nines_genres << genre unless nines_genres.include?(genre)
			end
		end
		return nines_genres
	end

	def self.estc_uri(rec)
		self.must_exist(rec,'035','a')
		fld = self.first_field(rec,'035','a')
		if fld == nil || fld.length == 0
			return ""
		else
			return fld.sub("(CU-RivES)","")
		end
	end

	def self.bancroft_title(rec)
		# bancroft stores titles in weird places sometimes
		id = self.first_field(rec,'001',' ')
		title_location = TitleCodeExceptions::TITLE_CODE_EXCEPTIONS[id]
		if title_location
			return self.combined_field(rec, title_location, ' ')
		else
			return self.parse_title(rec)
		end
	end

	def self.parse_title(rec)
		title = ''
		subtitle = ''

		title = self.combined_field(rec, '245', 'a')
		if title.length == 0
			rec = self.combined_field(rec, '260', 'a')
		end
		subtitle = self.combined_field(rec, '245', 'b')

		if subtitle.length > 0 ## if we have a subtitle, append it to the title nicely
			fulltitle = title + " " + subtitle.chomp('/')
		else
			fulltitle = title.chomp("/")
		end
		return fulltitle.sub(/[,;:]$/,"").strip
	end

end
