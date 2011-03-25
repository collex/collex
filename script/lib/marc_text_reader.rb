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

# This reads a text file with marc records formatted in it, interprets it, then calls RegenerateRdf for output.
# A way to generate this file from marc records is to use:
#
# http://people.oregonstate.edu/~reeset/marcedit/html/downloads.html
#Open MarcEdit and click on "MARC Tools" -- then select "MarcBreaker"
#and check "Translate to UTF-8".  The resulting output file will be
#a text file that is ready for editing.  Diacritics and special
#characters will be represented by entity references.
# Also, be sure that the character conversion is set to "canonical".

require "#{Rails.root}/script/lib/marc_to_solr.rb"

class MarcTextReader
	def self.read_folder(src_path, dst_path, archive, max_records, logs)
		url_log_path = logs[:url_log_path]
		progress_log_path = logs[:progress_log_file]
		error_log_path = logs[:error_log_file]
		@url_log = File.open(url_log_path, 'w')
		@progress_log = File.open(progress_log_path, 'w')
		@error_log = File.open(error_log_path, 'w')

		# read in the list of terms to ignore in the year field
		year_ignore = nil
		begin
			File.open("#{src_path}/year_ignore.txt", "r") { |f|
				year_ignore = f.read
				year_ignore = year_ignore.split("\n")
				year_ignore.delete_if { |yr| yr.strip() == '' }
				year_ignore = /#{year_ignore.join('|')}/
			}
		rescue
		end

		Dir.foreach(src_path) { |f|
			if f.index('.txt') == f.length - 4 && f != 'year_ignore.txt'
				hits = []
				fname = f.slice(0, f.length - 4)
				fp = File.open("#{src_path}/#{f}")
				print "Parsing #{f}"
				rec = self.get_next_document(fp)
				count = 0
				while rec != nil && (max_records == nil || count < max_records)
					#self.dump_document(rec)
					hit = self.create_document(rec, archive, year_ignore)
					#self.dump_uri(rec,hit)
					hits.push(hit) if hit
					rec = self.get_next_document(fp)
					count += 1
					if count % 10000 == 0
						puts "+"
					elsif count % 1000 == 0
						print '+'
					elsif count % 100 == 0
						print '.'
					end
				end
				hits.sort! { |a,b| a[:uri] <=> b[:uri] }
				RegenerateRdf.regenerate_all(hits, "#{dst_path}/#{fname}", archive)
			end
		}
	end

	private

	def self.close_logs()
		@url_log.close
		@progress_log.close
		@error_log.close
	end

	def self.log_error(str)
		@error_log.puts("#{Time.now}: #{str}")
	end

	def self.log_progress(str)
		@progress_log.puts("#{Time.now}: #{str}")
		@progress_log.flush()
	end

	def self.dump_uri(rec, hit)
		puts "#{rec['001'][' '][0]} : #{hit[:uri]}"
	end

	def self.dump_document(rec)
		rec.each { |key,value|
			puts "---- #{key} ----"
			value.each { |subkey, fields|
				puts "    #{subkey}: #{fields.join(' ### ')}"
			}
		}
	end

	def self.create_document(rec, archive, year_ignore)
		return MarcToSolr.convert(rec, archive, year_ignore)
	end

	def self.get_next_document(fp)
		# This reads some lines from the open file passed to it and returns a hash with the marc field and subfields
		rec = {}
		while true
			line = fp.gets
			if line == nil
				return nil
			end
			line = line.strip()
			prefix = line[0..3]
			case prefix
			when "" then
				# Just skip blank lines if the record is empty, otherwise that is the terminator
				if rec.length > 0
					return rec
				end
			when "=LDR" then
				# This must be the first non blank line
				rec = {}
			when /=\d\d\d/ then
				# this is a regular field. Store it, or split it into subfields and store them.
				prefix = prefix[1..3]
				if rec[prefix] == nil
					rec[prefix] = {}
				end
				line = line[5..line.length]
				begin
					line = line.gsub(/\\+/, ' ')	# TODO-PER: should we care about the slashes?
				rescue Exception => e
					self.log_error("Parsing error: #{e.to_s} in document #{rec['001']}")
					if e.to_s == "invalid byte sequence in UTF-8"
						arr = line.unpack('C*')
						line = arr.pack('U*')
						line = line.gsub(/\\+/, ' ')
					end
				end
				arr = line.split('$')
				if arr.length == 1
					if rec[prefix][' '] == nil
						rec[prefix][' '] = []
					end
					rec[prefix][' '].push(line.strip())
				else
					# The first element of the array is before the first field marker, so it is ignored. The first
					# character of the other elements is the subfield indicator, then the rest is the value.
					arr.shift()	# get rid of the first element
					arr.each {|field|
						sub = field[0..0]
						field = field[1..field.length]
						if rec[prefix][sub] == nil
							rec[prefix][sub] = []
						end
						rec[prefix][sub].push(field.strip()) if field
					}
				end
			else
				self.log_error("Unrecognized line: #{line}")
			end
		end

	end
end
