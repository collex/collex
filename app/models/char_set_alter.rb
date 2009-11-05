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
require 'iconv'

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
end
