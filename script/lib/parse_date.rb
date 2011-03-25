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

class ParseDate
	def self.extract_year(years, year_ignore)	# pass an array of the raw fields that come from field 260c
		#record.extract('260c').collect {|f| f.scan(/\d\d\d\d/)}.flatten
		result = []
		years.each {|year|
			# First remove any known garbage that is harmless
			orig_year = year
#			if orig_year == "[179O?]"
#				puts "found"
#			end
			year = year.chomp('.')
			year = year.gsub(year_ignore, ' ')	if year_ignore
			year = year.gsub("[", '').gsub("]", '').gsub("?", ' ').gsub(",", ' ').gsub("(", ' ').gsub(")", ' ')	# TODO-PER: change ? to a circa
			year = "1792-1796" if year == "1972-1796"
			arr = year.scan(/(1[56789]\d[\dO]|-|\/|\sand\s|\sor\s|\d\d|\d|circa|ca\.|ca|c)/)
			# The tokens pulled out are 4- 2- and 1-digit numbers, the hyphen, the slash, and the word 'and', or a 'c'.
			# We don't want anything before the first 4-digit number, then if the next token is hyphen, slash or 'and',
			# then we want to create a range with the first and the next number (that can be 1,2, or 4 digits). If a 4-digit number
			# follows another, then it is not a range, it is just added normally. If an unexpected sequence occurs, then just ignore it.
			# The reason unknown sequences should be ignored is that they may be part of a month and day or extra comments, so
			# it doesn't necessarily indicate an error.
			# actually, we also want a c before a 4-digit number, and a two digit number followed by 2 dashes.
			state = :start
			start_range = nil
			arr.each {|match|
				MarcTextReader.log_error("MATCH NOT ONE ELEMENT: #{match.join(',')}") if match.length != 1
				match = match[0]
				match = '' if match == nil
				case state
				when :start then
					# only accept a full date here
					if match.length == 4
						y = match.to_i
						y *= 10 if y < 1000	# if the last character must have been an oh instead of a zero
						result.push(y)
						state = :divider
						start_range = match.to_i
					elsif match == 'c' || match == 'ca'
						state = :circa
					elsif match.length == 2
						state = :first_dash
						start_range = match.to_i
					end

				when :first_dash then
					if match == '-'
						state = :second_dash
					else
						state = :start
					end

				when :second_dash then
					if match == '-'
						(start_range*100).upto((start_range+1)*100) { |x|
							result.push(x)
						}
					end
					state = :start

				when :circa then
					if match.length == 4
						(match.to_i - 5).upto(match.to_i + 5) { |x|
							result.push(x)
						}
					end
					state = :start

				when :divider then
					# accept another full date, or a divider
					if match.length == 4
						result.push(match.to_i)
						state = :divider
						start_range = match.to_i
					elsif match == ' and ' || match == '/' || match == '-' || match == ' or '
						state = :range
					else
						state = :start
					end

				when :range then
					# this can be a 1-, 2-, or 4-digit number to complete the range
					num = match.to_i	# normalize the date to 4 digits
					if num > 1000
						# nothing to do
					elsif num > 9
						num = "#{start_range}"[0..1].to_i * 100 + num
					elsif num > 0
						num = "#{start_range}"[0..2].to_i * 10 + num
					end
					start_range.upto(num) {|y|
						result.push(y)
					}
					state = :start
				end
			}
			# for debugging, print out anything we didn't use
			if arr.join('').gsub(' ', '') != year.gsub(' ', '')
				MarcTextReader.log_error("Unrecognized: #{orig_year} | #{year} | #{arr.join(',')}")
			end
		}
		return { :years => result.uniq, :year_sort => result.length > 0 ? [ result[0] ] : [], :date_label => years.join(' ') }
	end

	def self.reconstruct_date_label(years)
	# years is an array of 4-digit dates. We want to sort them, and combine the ones that are near each other with a hyphen.
		recs = years.sort
		yrs = []
		recs.each {|rec|
			rec = rec.to_i
			if yrs.length == 0
				yrs.push({ :start => rec, :end => rec })
			else
				if yrs[yrs.length-1][:end] == rec-1
					yrs[yrs.length-1][:end] = rec
				else
					yrs.push({ :start => rec, :end => rec })
				end
			end
		}
		yrs.collect! { |yr|
			if yr[:start] == yr[:end]
				yr[:start]
			else
				"#{yr[:start]}-#{yr[:end]}"
			end
		}
		#puts "=#{yrs.join(', ')}=" if recs.length > 1
		return yrs.join(', ')
	end
end
