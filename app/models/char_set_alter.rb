# encoding: UTF-8
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

class CharSetAlter
  def initialize
    
  end

#CP_MAP = {
#	"\x80" => "U+20AC",    # EURO SIGN
#	"\x82" => "U+201A",    # SINGLE LOW-9 QUOTATION MARK
#	"\x83" => "U+0192",    # LATIN SMALL LETTER F WITH HOOK
#	"\x84" => "U+201E",    # DOUBLE LOW-9 QUOTATION MARK
#	"\x85" => "U+2026",    # HORIZONTAL ELLIPSIS
#	"\x86" => "U+2020",    # DAGGER
#	"\x87" => "U+2021",    # DOUBLE DAGGER
#	"\x88" => "U+02C6",    # MODIFIER LETTER CIRCUMFLEX ACCENT
#	"\x89" => "U+2030",    # PER MILLE SIGN
#	"\x8A" => "U+0160",    # LATIN CAPITAL LETTER S WITH CARON
#	"\x8B" => "U+2039",    # SINGLE LEFT-POINTING ANGLE QUOTATION MARK
#	"\x8C" => "U+0152",    # LATIN CAPITAL LIGATURE OE
#	"\x8E" => "U+017D",    # LATIN CAPITAL LETTER Z WITH CARON
#
#	"\x91" => "U+2018",    # LEFT SINGLE QUOTATION MARK
#	"\x92" => "U+2019",    # RIGHT SINGLE QUOTATION MARK
#	"\x93" => "U+201C",    # LEFT DOUBLE QUOTATION MARK
#	"\x94" => "U+201D",    # RIGHT DOUBLE QUOTATION MARK
#	"\x95" => "U+2022",    # BULLET
#	"\x96" => "U+2013",    # EN DASH
#	"\x97" => "U+2014",    # EM DASH
#	"\x98" => "U+02DC",    # SMALL TILDE
#	"\x99" => "U+2122",    # TRADE MARK SIGN
#	"\x9A" => "U+0161",    # LATIN SMALL LETTER S WITH CARON
#	"\x9B" => "U+203A",    # SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
#	"\x9C" => "U+0153",    # LATIN SMALL LIGATURE OE
#	"\x9E" => "U+017E",    # LATIN SMALL LETTER Z WITH CARON
#	"\x9F" => "U+0178",    # LATIN CAPITAL LETTER Y WITH DIAERESIS
#}
#CP1252 = CP_MAP.keys.join
#UTF = CP_MAP.values.join
=begin
# TODO-PER: iconv is deprecated, so if we ever need this again, rewrite it.
require 'iconv'

	def self.translate(text)
		# this is being done by hand instead of using iconv because the data in the DB seems to be mixed: some is already utf-8 and some appears to be garbage.
		new_text = text.gsub("â€™", '’')
		new_text = new_text.gsub("â€”", '—')
		new_text = new_text.gsub("â€œ", '“')
		new_text = new_text.gsub("â€•", '―')
		new_text = new_text.gsub("â€“", '–')
		new_text = new_text.gsub("â€˜", '‘')
		new_text = new_text.gsub("â€¦", '…')
		new_text = new_text.gsub("â†’", '→')
		new_text = new_text.gsub("â€¡", '‡')
		new_text = new_text.gsub("â€ ", '†')
		new_text = new_text.gsub("â€", '”')
		new_text = new_text.gsub("â€¢", '•')

		new_text = new_text.gsub("Ã ", 'à')
		new_text = new_text.gsub("Ã¡", 'á')
		new_text = new_text.gsub("Ã¢", 'â')
		new_text = new_text.gsub("Ã¤", 'ä')
		new_text = new_text.gsub("Ã", 'Á')
		new_text = new_text.gsub("Ã¦", 'æ')
		new_text = new_text.gsub("Ã†", 'Æ')

		new_text = new_text.gsub("ÃŸ", 'ß')
		new_text = new_text.gsub("Ã§", 'ç')

		new_text = new_text.gsub("Ã‰", 'É')
		new_text = new_text.gsub("Ãˆ", 'È')
		new_text = new_text.gsub("Ã«", 'ë')
		new_text = new_text.gsub("Ã¨", 'è')
		new_text = new_text.gsub("Ã©", 'é')
		new_text = new_text.gsub("Ãª", 'ê')

		new_text = new_text.gsub("ÃŒ", 'Ì')
		new_text = new_text.gsub("Ã­", 'í')
		new_text = new_text.gsub("Ã¯", 'ï')
		new_text = new_text.gsub("Ã¬", 'ì')

		new_text = new_text.gsub("Ã³", 'ó')
		new_text = new_text.gsub("Ã¶", 'ö')
		new_text = new_text.gsub("Ã²", 'ò')
		new_text = new_text.gsub("Ãµ", 'õ')

		new_text = new_text.gsub("Ãº", 'ú')
		new_text = new_text.gsub("Ã¹", 'ù')
		new_text = new_text.gsub("Ã¼", 'ü')

		new_text = new_text.gsub("Ã±", 'ñ')
		return new_text
	end

	def self.fix_cp1252(table, column, debug)
		ActiveRecord::Base.record_timestamps = false if debug == false
		table.record_timestamps = false if debug == false
		# This reads all the columns in the table, attempts to apply the conversion, and reports the results
		ic = Iconv.new('CP1252', 'UTF-8')
		recs = table.all()
		num_changes = 0
		num_failed_changes = 0
		failures = []
		puts "=============================================="
		puts "#{table.to_s}:#{column.to_s} (#{recs.length})"
		recs.each {|rec|
			text = rec[column]
			if text != nil
				# this is being done by hand instead of using iconv because the data in the DB seems to be mixed: some is already utf-8 and some appears to be garbage.
				new_text = text.gsub("â€™", '’')
				new_text = new_text.gsub("â€”", '—')
				new_text = new_text.gsub("â€œ", '“')
				new_text = new_text.gsub("â€•", '―')
				new_text = new_text.gsub("â€“", '–')
				new_text = new_text.gsub("â€˜", '‘')
				new_text = new_text.gsub("â€¦", '…')
				new_text = new_text.gsub("â†’", '→')
				new_text = new_text.gsub("â€¡", '‡')
				new_text = new_text.gsub("â€ ", '†')
				new_text = new_text.gsub("â€", '”')
				new_text = new_text.gsub("â€¢", '•')

				new_text = new_text.gsub("Ã ", 'à')
				new_text = new_text.gsub("Ã¡", 'á')
				new_text = new_text.gsub("Ã¢", 'â')
				new_text = new_text.gsub("Ã¤", 'ä')
				new_text = new_text.gsub("Ã", 'Á')
				new_text = new_text.gsub("Ã¦", 'æ')
				new_text = new_text.gsub("Ã†", 'Æ')

				new_text = new_text.gsub("ÃŸ", 'ß')
				new_text = new_text.gsub("Ã§", 'ç')

				new_text = new_text.gsub("Ã‰", 'É')
				new_text = new_text.gsub("Ãˆ", 'È')
				new_text = new_text.gsub("Ã«", 'ë')
				new_text = new_text.gsub("Ã¨", 'è')
				new_text = new_text.gsub("Ã©", 'é')
				new_text = new_text.gsub("Ãª", 'ê')

				new_text = new_text.gsub("ÃŒ", 'Ì')
				new_text = new_text.gsub("Ã­", 'í')
				new_text = new_text.gsub("Ã¯", 'ï')
				new_text = new_text.gsub("Ã¬", 'ì')

				new_text = new_text.gsub("Ã³", 'ó')
				new_text = new_text.gsub("Ã¶", 'ö')
				new_text = new_text.gsub("Ã²", 'ò')
				new_text = new_text.gsub("Ãµ", 'õ')

				new_text = new_text.gsub("Ãº", 'ú')
				new_text = new_text.gsub("Ã¹", 'ù')
				new_text = new_text.gsub("Ã¼", 'ü')

				new_text = new_text.gsub("Ã±", 'ñ')

				i1 = new_text.index('â')
				i2 = new_text.index('Ã')
				if i1 || i2
					if i1 == nil
						i = i2
					elsif i2 == nil
						i = i1
					else
						i = i1 > i2 ? i2 : i1
					end
#					str = new_text[i..new_text.length]
					str = new_text[i..(i+10)]
					arr = str.split("\n")
					str = arr[0]
					begin
						new_text2 = ic.iconv(str)
						puts "#{rec.id}: #{str}"
						puts "#{rec.id}: #{new_text2}"
					rescue
						print "#{rec.id}: "
						failures.push(rec.id)
						str.each_byte {|c| print c, ' ' }
						puts "FAILED: #{str}"
						num_failed_changes += 1
					end
				end
				if (text != new_text)
					rec[column] = new_text
					# update the field without changing the timestamp
					rec.update_attribute(column, new_text) if debug == false
					num_changes += 1
				end
			end
		}
		table.record_timestamps = true if debug == false
		ActiveRecord::Base.record_timestamps = true if debug == false
		puts "Num of changes: #{num_changes}; failures (#{num_failed_changes}): [#{failures.join(" ")}]"
	end

	def self.cp1252_to_utf8(table, column, debug)
		ActiveRecord::Base.record_timestamps = false if debug == false
		table.record_timestamps = false if debug == false
		converter = Iconv.new('UTF-8','CP1252')
		recs = table.all()
		num_changes = 0
		num_failed_changes = 0
		failures = []
		recs.each {|rec|
			text = rec[column]
			has_error = false
			if text != nil
				text.each_byte {|by|
					if (by > 127 && by < 128+32)
						has_error = true
					end
				}
			end
			
			if has_error == true
				begin
					new_text = converter.iconv(text)
					#new_text = text.tr(CP1252,u(UTF))
					rec[column] = new_text
					# update the field without changing the timestamp
					rec.update_attribute(column, new_text) if debug == false
					#table.update_all( "#{column.to_s()} = '#{new_text}'", id = rec.id ) if debug == false
					num_changes += 1
				rescue
					failures.push(rec.id)
					num_failed_changes += 1
				end
			end
		}
		puts "#{table.to_s}:#{column.to_s} (#{recs.length}) Number of changes: #{num_changes}; failures: [#{failures.join(" ")}]"
		ActiveRecord::Base.record_timestamps = true if debug == false
	end

	def self.downcase_tag()
		recs = Tag.all()
		num_changed = 0
		recs.each {|rec|
			tag = rec.name.downcase()
			if tag != rec.name
				puts tag
				num_changed +=1
				rec.name = tag
				rec.save
			end
		}
		puts "Changed: #{num_changed}"
	end
=end
end
