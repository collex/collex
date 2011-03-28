# encoding: UTF-8
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

# This contains routines to test two solr objects
class CompareSolrObject
	def self.add_error(uri, total_errors, first_error, msg, err_arr)
		err_arr.push("---#{uri}---\n") if first_error
		total_errors += 1
		first_error = false
		err_arr.push("    #{msg}\n")
		return total_errors, first_error
	end

	def self.not_ignored_required_field(archive, field)
		# This is a hack to make the output more manageable in the cases where we know there are lots of errors in our index.
		# All of these should eventually go away.
		return false if (field == 'year')
		return false if (field == 'year_sort')
		return false if (field == 'author_sort')
		return false if (field == 'title')
		return false if (field == 'title_sort')
		return false if (field == 'url' && archive == 'whitbib')
		return true
	end

	def self.not_ignored_introduced_field(archive, field)
		# This is a hack to make the output more manageable in the cases where we know there are lots of errors in our index.
		# All of these should eventually go away.
		return false if (field == 'year_sort')
		return false if (field == 'has_full_text')
		return false if (field == 'freeculture')
		return false if (field == 'is_ocr')
		return false if (field == 'author_sort')
		return true
	end

	def self.replace_unicode(text)
		text = text.gsub("&#233;", "é")
		text = text.gsub("&#246;", "ö")
		text = text.gsub("&#230;", "æ")
		text = text.gsub("&#339;", "œ")
		text = text.gsub("&#198;", "Æ")
		text = text.gsub("&#38;", "&")
		text = text.gsub("&#8224;", "†")
		text = text.gsub("&#8224;", "†")
		text = text.gsub("&#166;", "¦")
		text = text.gsub("&#8220;", "“")
		text = text.gsub("&#8217;", "’")
		return text
	end

	def self.processed_original_field(str)
		# This is a hack to make the output more manageable in the cases where we know there are lots of errors in our index.
		# All of these should eventually go away.
#		return str
		str = str.gsub("\n", ' ')
		str = self.remove_extra_white_space(str)
		return replace_unicode(str).gsub('&amp;', '&').gsub("&#38;", '&').chomp(' ');
	end

	def self.processed_reindexed_field(str)
		# This is a hack to make the output more manageable in the cases where we know there are lots of errors in our index.
		# All of these should eventually go away.
		return str
#		return str.gsub('&amp;', '&')
	end

	def self.remove_extra_white_space(text)
		text = text.gsub("\t", " ")	# change tabs to spaces
		text = text.gsub(/\ +/, " ")	# get rid of multiple spaces
		text = text.gsub(" \n", "\n") # get rid of trailing spaces
		text = text.gsub("\n ", "\n")	# get rid of leading spaces
		text = text.gsub(/\n+/, "\n")	# get rid of blank lines
		return text
	end

	def self.processed_original_text(text)
		# This is a hack to make the output more manageable in the cases where we know there are lots of errors in our index.
		# All of these should eventually go away.

		text = text.gsub("\n", ' ')
		text = self.remove_extra_white_space(text)

		text = text.gsub("““", "“")
		text = text.gsub("””", "””")
		text = text.gsub("††", "†")
#		text = text.gsub("’’", "’")
		text = text.gsub("〉〉", "〉")
		text = replace_unicode(text)
		text = text.gsub(/—+/, '—')

		return text
	end

	def self.processed_reindexed_text(text)
		# This is a hack to make the output more manageable in the cases where we know there are lots of errors in our index.
		# All of these should eventually go away.

		text = self.remove_extra_white_space(text)

		text = text.gsub("““", "“")
		text = text.gsub("””", "””")
		text = text.gsub(/—+/, '—')
		text = text.gsub("††", "†")
#		text = text.gsub("’’", "’")
		
		return text
	end

	def self.value_to_string(value)
		if value.kind_of?(Array)
			value.each_with_index{ |v,i|
				value[i] = v.strip()
			}
			value = value.join(" | ")
		elsif value != nil
			value = "#{value}".strip()
		end
		return value
	end

	def self.compare_objs(new_obj, old_obj, total_errors)	# this compares one object from the old and new indexes
		err_arr = []
		uri = new_obj['uri']
		first_error = true
		required_fields = [ 'title_sort', 'title', 'genre', 'archive', 'url', 'federation', 'year_sort', 'freeculture', 'is_ocr' ]
		required_fields.each {|field|
			if self.not_ignored_required_field(new_obj['archive'], field)
				if new_obj[field] == nil
					total_errors, first_error = self.add_error(uri, total_errors, first_error, "required field: #{field} missing in new index", err_arr)
				elsif new_obj[field].kind_of?(Array) && new_obj[field].length == 0
					total_errors, first_error = self.add_error(uri, total_errors, first_error, "required field: #{field} is NIL in new index", err_arr)
				elsif new_obj[field].kind_of?(Array) && new_obj[field].join('').strip().length == 0
					total_errors, first_error = self.add_error(uri, total_errors, first_error, "required field: #{field} is an array of all spaces in new index", err_arr)
				elsif new_obj[field].kind_of?(String) && new_obj[field].strip() == ""
					total_errors, first_error = self.add_error(uri, total_errors, first_error, "required field: #{field} is all spaces in new index", err_arr)
				end
			end
		}
		if old_obj == nil
			# total_errors, first_error = self.add_error(uri, total_errors, first_error, "Document #{uri} introduced in reindexing.")
		else
			new_obj.each {|key,value|
				if key == 'batch' || key == 'score'
					old_obj.delete(key)
				else
					old_value = old_obj[key]
					old_value = self.value_to_string(old_value)
					value = self.value_to_string(value)
#					if key == 'text' || key == 'title'
#						old_value = old_value.strip if old_value != nil
#						value = value.strip if value != nil
#					end
					if old_value == nil
						if self.not_ignored_introduced_field(new_obj['archive'], key)
							total_errors, first_error = self.add_error(uri, total_errors, first_error, "#{key} #{value.gsub("\n", " / ")} introduced in reindexing.", err_arr)
						end
					elsif old_value != value
						if self.processed_original_field(old_value) != self.processed_reindexed_field(value)
							if old_value.length > 30
								total_errors, first_error = self.add_error(uri, total_errors, first_error, "#{key} mismatched: length= #{value.length} (new) vs. #{old_value.length} (old)", err_arr)
								old_arr = old_value.split("\n")
								new_arr = value.split("\n")
								first_mismatch = -1
								old_arr.each_with_index { |s, i|
									first_mismatch = i if first_mismatch == -1 && new_arr[i] != s
								}
								total_errors, first_error = self.add_error(uri, total_errors, first_error, "        at line #{first_mismatch}:\n\"#{new_arr[first_mismatch].gsub("\n", " / ")}\" vs.\n\"#{old_arr[first_mismatch].gsub("\n", " / ")}\"\n", err_arr)
							else
								total_errors, first_error = self.add_error(uri, total_errors, first_error, "#{key} mismatched: \"#{value.gsub("\n", " / ")}\" (new) vs. \"#{old_value.gsub("\n", " / ")}\" (old)", err_arr)
							end
						end
					end
					old_obj.delete(key)
				end
			}
			old_obj.each {|key,value|
				if value != nil # && key != 'type'	# 'type' is being phased out, so it is ok if it doesn't appear.
					value = self.value_to_string(value)
					value = value.slice(0..99) + "..." if value.length > 100
					value = value.gsub("\n", " / ")
					if value.length > 0
						total_errors, first_error = self.add_error(uri, total_errors, first_error, "Key not reindexed: #{key}=#{value}", err_arr)
					end
				end
			}
		end
		return total_errors, err_arr
	end

	def self.compare_text(new_obj, old_obj, total_errors, docs_with_text)
		err_arr = []
		uri = new_obj['uri']

		if old_obj['text'] == nil
			#old_text = ""
		elsif old_obj['text'].length > 1
			err_arr.push("#{uri} old text is an array of size #{old_obj['text'].length}\n")
			old_text = old_obj['text'].join(" | ").strip()
		else
			old_text = old_obj['text'][0].strip
		end

		if new_obj['text'] == nil
			if new_obj['has_full_text'] != false
				err_arr.push("#{uri} field has_full_text is #{new_obj['has_full_text']} but full text does not exist.\n")
				total_errors += 1
			end
			if new_obj['is_ocr'] == true
				err_arr.push("#{uri} field is_ocr exists and is #{new_obj['is_ocr']} but full text does not exist.\n")
				total_errors += 1
			end
		elsif new_obj['text'].length > 1
			err_arr.push("#{uri} new text is an array of size #{new_obj['text'].length}\n")
				total_errors += 1
			text = new_obj['text'].join(" | ").strip()
		else
			docs_with_text += 1
			text = new_obj['text'][0].strip
#			if new_obj['is_ocr'] == true
#				err_arr.push("#{uri} field is_ocr exists and is #{new_obj['is_ocr']} but full text exists.\n")
#				total_errors += 1
#			end
		end
		
		# attempt a junk gsub on the text. If there are invalid characters in the text
		# this method will throw. Catch it, log the invalid UTF and move on.
		# Do this for bot old nd new text
		if text != nil
		  begin
		    text.gsub('a', ' ')
		  rescue
		    err_arr.push("#{uri} (new) contains full text with illegal UTF-8 characters")  
        total_errors+=1
        return total_errors, err_arr, docs_with_text
		  end
		end
		
		if old_text != nil
      begin
        old_text.gsub('a', ' ')
      rescue
        err_arr.push("#{uri} (old) contains full text with illegal UTF-8 characters")
        total_errors+=1
        return total_errors, err_arr, docs_with_text
      end
    end

		if text == nil && old_text != nil
			err_arr.push("#{uri} text field has disappeared from the new index. (old text size = #{old_text.length})\n")
			total_errors += 1
		elsif text != nil && old_text == nil
			err_arr.push("#{uri} text field has appeared in the new index.\n")
			total_errors += 1
		elsif text != old_text
			# delete unimportant differences and known bugs and try again.
			text = self.processed_reindexed_text(text)
			old_text = self.processed_original_text(old_text)

			if text != old_text
				old_arr = old_text.split("\n")
				old_arr.delete("")
				new_arr = text.split("\n")
				new_arr.delete("")
				first_mismatch = -1
				old_arr.each_with_index { |s, j|
					if first_mismatch == -1 && new_arr[j] != s
						first_mismatch = j
					end
				}
				if first_mismatch == -1	&& new_arr.length != old_arr.length # if the new text has more lines than the old text
					first_mismatch = old_arr.length
				end
				if first_mismatch != -1
					print_start = first_mismatch - 1
					print_start = 0 if print_start < 0

					str_n = new_arr[first_mismatch]
					str_o = old_arr[first_mismatch]
					len = str_n.length > str_o.length ? str_n.length : str_o.length

					miss_index = -1
					len.times { |x|
						if str_n[x] != str_o[x]
							miss_index = x
							break
						end
					}
					miss_index -= 4
					miss_index = 0 if miss_index < 0

					err_arr.push("==== #{uri} mismatch at line #{first_mismatch}:col #{miss_index}:\n(new #{text.length})")
					err_arr.push(str_n[miss_index..30])
#					print_end = first_mismatch + 1
#					print_end = new_arr.length() -1 if print_end >= new_arr.length()
#					print_start.upto(print_end) { |x|
#						err_arr.push("\"#{new_arr[x]}\"\n")
#					}
					err_arr.push("-- vs --\n(old #{old_text.length})")
					err_arr.push(str_o[miss_index..30])
#					print_end = first_mismatch + 1
#					print_end = old_arr.length() -1 if print_end >= old_arr.length()
#					print_start.upto(print_end) { |x|
#						err_arr.push("\"#{old_arr[x]}\"\n")
#					}

					bytes_n = ""
					bytes_o = ""
					str_n = str_n[miss_index..str_n.length]
					str_o = str_o[miss_index..str_o.length]
					str_n.each_byte { |x|
						bytes_n += "#{x} "
						break if bytes_n.length > 45
					}
					str_o.each_byte { |x|
						bytes_o += "#{x} "
						break if bytes_o.length > 45
					}
					err_arr.push("NEW: #{bytes_n}")
					err_arr.push("OLD: #{bytes_o}")
					#CollexEngine.report_line("#{text}\n----\n#{old_text}\n")
					#CollexEngine.report_line("#{text}\n")
					total_errors += 1
				end
			end
		end

		return total_errors, err_arr, docs_with_text
	end
end
