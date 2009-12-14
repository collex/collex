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

require 'solr'

class CollexEngine
	CORE = [ "resources" ]
	
  def initialize(cores=CORE)
    @num_docs = -1
		@cores = []
		prefix = SOLR_URL.slice(7..SOLR_URL.length)	# this removes the "http://" part
		cores.each {|core|
			@cores.push("#{prefix}/#{core}")
		}

    @solr = Solr::Connection.new(SOLR_URL+ '/' + cores[0])
		@field_list = [ "uri", "archive", "date_label", "genre", "source", "image", "thumbnail", "title", "alternative", "url",
			"role_ART", "role_AUT", "role_EDT", "role_PBL", "role_TRL", "role_EGR", "role_ETR", "role_CRE", "freeculture",
			"is_ocr", "federation", "has_full_text", "source_xml" ]
    @all_fields_except_text = @field_list + [ "publisher", "agent", "agent_facet", "author", "batch", "editor",
			"text_url", "year", "type", "date_updated", "title_sort", "author_sort", "year_sort", "source_html", "source_sgml", "person", "format", "language", "geospacial" ]
		@facet_fields = ['genre','archive','freeculture', 'has_full_text']
  end

	def self.factory_create(testing)
		if testing
			cores = self.get_archive_core_list()
			return CollexEngine.new(cores)
		else
			return CollexEngine.new()
		end
	end

	def self.get_num_docs()	# this always gets just the number of documents in the main index, no matter how many indexes are used.
		return CollexEngine.new().num_docs
	end

  def num_docs	# called for each entry point to get the number for the footer.
    if @num_docs == -1
      request = Solr::Request::Standard.new(:query=>"*:*", :rows=>0, :shards => @cores)
      response = @solr.send(request)
      
      @num_docs = response.total_hits
    end
    
    @num_docs
  end

	# TODO-PER: rename this to autocomplete
  def facet(facet, constraints, prefix=nil)	# called for autocomplete
    query, filter_queries = solrize_constraints(constraints)
    req = Solr::Request::Standard.new(
            :start => 0, :rows => 0, :shards => @cores,
            :query => query, :filter_queries => filter_queries,
            :facets => {:fields => [facet], :mincount => 1, :missing => (prefix ? false : true), :limit => -1, :prefix => prefix, :method => 'enum'})

    response = @solr.send(req)
    facets_to_hash(response.data['facet_counts']['facet_fields'])[facet]
  end

	def tank_citations(query)
		return "(*:* AND #{query}) OR (*:* AND #{query} -genre:Citation)^5"
		#return "(#{query}) OR (#{query} -genre:Citation)^5"
	end

	def name_facet(constraints)
    query, filter_queries = solrize_constraints(constraints)
    req = Solr::Request::Standard.new(:start => 0, :rows => 0,
					:query => query, :filter_queries => filter_queries,
					:field_list => [ 'role_AUT', 'role_EDT', 'role_PBL'],
					:facets => {:fields => [ 'role_AUT', 'role_EDT', 'role_PBL'], :mincount => 1, :missing => false, :limit => -1},
					:shards => @cores)
    response = @solr.send(req)

		facets = response.data['facet_counts']['facet_fields']
    facets = facets_to_hash(facets)
		facets2 = {}
		facets.each { |ty, facet|
			facets2[ty] = facet.sort { |a,b| (a[1] == b[1]) ? a[0] <=> b[0] : b[1] <=> a[1] }
		}

		return facets2
	end

  def search(constraints, start, max, sort_by, sort_ascending)	# called when the user requests a search.
    query, filter_queries = solrize_constraints(constraints)

    # TODO: switch to DisMax (DisjunctionMaxQuery)
		if sort_ascending
			sort_param = sort_by ? [ { sort_by.to_sym => :ascending } ] : nil
		else
			sort_param = sort_by ? [ { sort_by.to_sym => :descending } ] : nil
		end
		#filter_queries.push("genre:\"Citation^.01\"")
		query = tank_citations(query)
    req = Solr::Request::Standard.new(:start => start, :rows => max, :sort => sort_param, #:alternate_query => "*:*",
					:query => query, :filter_queries => filter_queries,
					:field_list => @field_list,
					:facets => {:fields => @facet_fields, :mincount => 1, :missing => true, :limit => -1},
					:highlighting => {:field_list => ['text'], :fragment_size => 600, :max_analyzed_chars => 512000 }, :shards => @cores)
  
    results = {}
  
    response = @solr.send(req)
  
    results["total_hits"] = response.total_hits
    results["hits"] = response.hits

		# The freeculture field is either returned as nil, or it isn't present. Make the returned object a little more friendly.
		results["hits"].each { |hit|
			fix_free_culture(hit)
		}
    # Reformat the facets into what the UI wants, so as to leave that code as-is for now
    results["facets"] = facets_to_hash(response.data['facet_counts']['facet_fields'])
    results["highlighting"] = response.data['highlighting']
    return results
  end

	def fix_free_culture(hit)
			if hit.has_key?("freeculture")
				hit['freeculture'] = false
			else
				hit['freeculture'] = true
			end
	end

	def get_object(uri) #called when "collect" is pressed.
		# Returns nil if the object doesn't exist, or the object if it does.
    query = "uri:#{Solr::Util.query_parser_escape(uri)}"

    req = Solr::Request::Standard.new(
             :start => 0, :rows => 1,
             :query => query, :field_list => @field_list, :shards => @cores)

    response = @solr.send(req)
		if response.hits.length > 0
			fix_free_culture(response.hits[0])
	    return response.hits[0]
		end
		return nil
	end

	def get_object_with_text(uri)
		# Returns nil if the object doesn't exist, or the object if it does.
    query = "uri:#{Solr::Util.query_parser_escape(uri)}"

    req = Solr::Request::Standard.new(
             :start => 0, :rows => 1,
             :query => query, :shards => @cores)

    response = @solr.send(req)
    return response.hits[0] if response.hits.length > 0
		return nil
	end

	def add_object(fields, relevancy = nil) # called by Exhibit to index exhibits
		# this takes a hash that contains a set of fields expressed as symbols, i.e. { :uri => 'something' }
		doc = Solr::Document.new(fields)
		doc.boost = relevancy if relevancy != nil
		@solr.add(doc)
	end

	def commit()	# called by Exhibit at the end of indexing exhibits
		@solr.commit(:wait_searcher => false, :wait_flush => false, :shards => @cores)
	end

	def delete_archive(archive) #usually called when un-peer-reviewing an exhibit, but is also used for indexing.
		# Warning: This will delete all the documents in the archive!
		@solr.delete_by_query "+archive:#{archive.gsub(":", "\\:")}"
	end

#
# Everything below this point is for indexing and testing indexes.
#

#	def remove_object(uri)
#		@solr.delete(uri)
#	end

	# this merges the indexes passed into the current index
	def merge(indexes)
		arr = @cores[0].split('/')
		core = arr[arr.length-1]
		url = "#{SOLR_URL}/admin/cores?action=mergeindexes&core=#{core}"
		indexes.each{|index|
				url += "&indexDir=solr/data/#{index}/index"
		}
		puts "curl \"#{url}\""
		`curl \"#{url}\"`

		# this will timeout. Don't crash when that happens.
		begin
			@solr.optimize()
		rescue
	  end
		begin
			@solr.commit()
		rescue
		end
	end

	def self.merge_all_reindexed(exceptions)
		archives = get_archive_core_list()
		exceptions.collect! { |ex| "archive_#{ex}"}
		archives = archives - exceptions
		merged = CollexEngine.new(['merged'])
		merged.clear_index()
		merged.merge(archives)
	end

	def self.create_core(name)
		url = "#{SOLR_URL}/admin/cores?action=CREATE&name=#{name}&instanceDir=."

		puts "curl \"#{url}\""
		`curl \"#{url}\"`
	end

	public	# these should actually be some sort of private since they are only called inside this file.
	def get_page_in_archive(archive, page, size, field_list)
    query = "archive:#{Solr::Util.query_parser_escape(archive)}"

    req = Solr::Request::Standard.new(
             :start => page*size, :rows => size,	:sort => [ { :uri => :ascending } ],
             :query => query, :field_list => field_list)

    response = @solr.send(req)
    return response.hits
	end

  def get_all_archives
    results = search([], 1, 10, nil, true)
    found_resources = results['facets']['archive']
    resources = []
    found_resources.each {|key,val| resources.push(key)}
    return resources.sort()
  end

	def get_all_in_archive(archive, field_list)
		hits = []
		done = false
		page = 0
		size = 500
		while !done do
			these_hits = get_page_in_archive(archive, page, size, field_list)
			hits += these_hits
			done = these_hits.length < size
			page += 1
			print "."
		end
		return hits
	end

	def get_text_fields_in_archive(archive, page, size)
		return get_page_in_archive(archive, page, size, [ 'uri', 'text', 'is_ocr', 'has_full_text' ])
 	end

	def get_all_uris_in_archive(archive)
		return get_all_in_archive(archive, [ "uri" ])
	end

	def get_all_objects_in_archive(archive)
		return get_all_in_archive(archive, @all_fields_except_text)
	end

	public
	# Warning: This will completely wipe out the index. Just do this on the reindexing resource!
	def clear_index
		@solr.delete_by_query "*:*"
		@solr.optimize
	end

	def self.value_to_string(value)
		if value.kind_of?(Array)
			value.each{ |v|
				v = v.strip()
			}
			value = value.join(" | ")
		elsif value != nil
			value = "#{value}"
		end
		return value
	end

	public	# these should actually be some sort of private since they are only called inside this file.
	def self.compare_objs(new_obj, old_obj, total_errors)	# this compares one object from the old and new indexes
		uri = new_obj['uri']
		first_error = true
		required_fields = [ 'title_sort', 'title', 'genre', 'archive', 'url', 'federation', 'year_sort' ]	# 'year', 'author_sort', TODO: too many items are missing. Take care of that later.
		required_fields.each {|field|
			if field != 'url' || new_obj['archive'] != 'whitbib'	#TODO: remove this when new "resources" archive is created.
				if new_obj[field] == nil
					total_errors, first_error = print_error(uri, total_errors, first_error, "required field: #{field} missing in new index")
				elsif new_obj[field].length == 0
					total_errors, first_error = print_error(uri, total_errors, first_error, "required field: #{field} is NIL in new index")
				elsif new_obj[field].kind_of?(Array) && new_obj[field].join('').strip().length == 0
					total_errors, first_error = print_error(uri, total_errors, first_error, "required field: #{field} is an array of all spaces in new index")
				elsif !new_obj[field].kind_of?(Array) && new_obj[field].strip() == ""
					total_errors, first_error = print_error(uri, total_errors, first_error, "required field: #{field} is all spaces in new index")
				end
			end
		}
		if old_obj == nil
			# total_errors, first_error = print_error(uri, total_errors, first_error, "Document #{uri} introduced in reindexing.")
		else
			new_obj.each {|key,value|
				if key == 'batch' || key == 'score'
					old_obj.delete(key)
#				elsif key == 'federation' && value.to_s == "NINES"
#					# TODO: just ignore these for now. When the new index becomes the standard one, then remove this test.
#					old_obj.delete(key)
#				elsif key == 'federation' && value.join(",") == "NINES,18th Connect" && new_obj['archive'] == 'poetess'
#					# TODO: just ignore these for now. When the new index becomes the standard one, then remove this test.
#					old_obj.delete(key)
#				elsif key == 'has_full_text' || key == 'is_ocr'
#					# TODO: just ignore these for now. When the new index becomes the standard one, then remove this test.
#					old_obj.delete(key)
				else
					old_value = old_obj[key]
					old_value = value_to_string(old_value)
					value = value_to_string(value)
					if key == 'text' || key == 'title'
						old_value = old_value.strip if old_value != nil
						value = value.strip if value != nil
					end
					if old_value == nil
						if key != 'year_sort'	#TODO: to many errors: remove this test after "resources" index is recreated.
							total_errors, first_error = print_error(uri, total_errors, first_error, "#{key} #{value.gsub("\n", " / ")} introduced in reindexing.")
						end
					elsif old_value != value
						if old_value.gsub('&amp;', '&') != value.gsub('&amp;', '&')	# TODO: Straighten out &amp; bug.
							if old_value.length > 30
								total_errors, first_error = print_error(uri, total_errors, first_error, "#{key} mismatched: length= #{value.length} (new) vs. #{old_value.length} (old)")
								old_arr = old_value.split("\n")
								new_arr = value.split("\n")
								first_mismatch = -1
								old_arr.each_with_index { |s, i|
									first_mismatch = i if first_mismatch == -1 && new_arr[i] != s
								}
								puts "        at line #{first_mismatch}:\n\"#{new_arr[first_mismatch].gsub("\n", " / ")}\" vs.\n\"#{old_arr[first_mismatch].gsub("\n", " / ")}\""
							else
								total_errors, first_error = print_error(uri, total_errors, first_error, "#{key} mismatched: \"#{value.gsub("\n", " / ")}\" (new) vs. \"#{old_value.gsub("\n", " / ")}\" (old)")
							end
						end
					end
					old_obj.delete(key)
				end
			}
			old_obj.each {|key,value|
				if value != nil # && key != 'type'	# 'type' is being phased out, so it is ok if it doesn't appear.
					value = value_to_string(value)
					value = value.slice(0..99) + "..." if value.length > 100
					value = value.gsub("\n", " / ")
					if value.length > 0
						total_errors, first_error = print_error(uri, total_errors, first_error, "Key not reindexed: #{key}=#{value}")
					end
				end
			}
		end
		return total_errors
	end

	def self.compare_object_arrays(new_objs, old_objs, total_errors)
		# first turn the old objects into a hash for quicker searching
		old_hash = {}
		old_objs.each {|obj|
			uri = obj['uri']
			old_hash[uri] = obj
		}

		# now go through each item one by one and compare them.
		new_objs.each {|new_obj|
			uri = new_obj['uri']
			old_obj = old_hash[uri]
			total_errors = self.compare_objs(new_obj, old_obj, total_errors)
		}

		return total_errors
	end

	def self.get_archive_core_list()
		url = "#{SOLR_URL}/admin/cores?action=STATUS"
		resp = `curl #{url}`	# this returns some info on all the cores. We can ignore most of it, we are just looking for the names that start with "archive_"
		arr = resp.split('<lst name="archive_')
		arr.delete_at(0)	# this gets rid of the header.
		archives = []
		arr.each{ |a|
			arr2 = a.split('"')
			archives.push("archive_#{arr2[0]}")
		}
		return archives.sort()
	end

	public
	def self.compare_reindexed_core(params)
		archive_to_scan = params[:archive]
		start_after = params[:start_after]
		use_merged_index = params[:use_merged_index]
		resources = CollexEngine.new(['resources'])
		total_docs_scanned = 0
		total_errors = 0

		if archive_to_scan
			print "====== Scanning archive \"#{archive_to_scan}\"... ====== "
			if use_merged_index
				reindexed = CollexEngine.new(["merged"])
			else
				reindexed = CollexEngine.new(["archive_#{archive_to_core_name(archive_to_scan)}"])
			end
			new_obj = reindexed.get_all_objects_in_archive(archive_to_scan)
			print "retrieved #{new_obj.length} new rdf objects;"
			total_docs_scanned += new_obj.length
			old_obj = resources.get_all_objects_in_archive(archive_to_scan)
			puts "retrieved #{old_obj.length} old objects;"
			total_errors = self.compare_object_arrays(new_obj, old_obj, total_errors)
		else
			if use_merged_index
				archives = resources.get_all_archives()
			else
				archives = get_archive_core_list()
			end
			started = start_after == nil
			archives.each {|archive|
				if started
					print "====== Scanning archive \"#{archive}\"... ====== "
					if use_merged_index
						reindexed = CollexEngine.new(["merged"])
					else
						reindexed = CollexEngine.new(["#{archive}"])
						actual_archive_names = reindexed.get_all_archives()
						# theoretically there should be exactly one archive in each index. We'll make sure of that here.
						if actual_archive_names.length > 1
							puts "More than one archive in index: #{actual_archive_names.join(',')}"
						elsif actual_archive_names.length == 0
							puts "No archives present in the index. Is it empty?"
						else
							archive = actual_archive_names[0]
						end
					end

					new_obj = reindexed.get_all_objects_in_archive(archive)
					print "retrieved #{new_obj.length} new rdf objects;"
					total_docs_scanned += new_obj.length
					old_obj = resources.get_all_objects_in_archive(archive)
					puts "retrieved #{old_obj.length} old objects;"
					total_errors = self.compare_object_arrays(new_obj, old_obj, total_errors)
					
				else	# is started
					if archive == "archive_#{start_after}"
						started = true
					end
				end
			}
		end
		puts "Total Docs Scanned: #{total_docs_scanned}. Total Errors: #{total_errors}. Total Docs in index: #{resources.num_docs()}"
	end

	public	# these should actually be some sort of private since they are only called inside this file.
	def self.trans_str(str)
		return str
#		ret = ""
#		str.to_s.each_char(){ |ch|
#			"#{ch}".each_byte { |c|
#				if (c >= 32 && c <= 127) || c == 10
#					ret += ch
#				else
#					ret += "~#{c}~"
#				end
#			}
#		}
#		return ret
	end

	def self.compare_text_one_archive(archive, reindexed_core, old_core)
			puts "====== Scanning archive \"#{archive}\"... ====== "
			start_time = Time.now
			done = false
			page = 0
			size = 10
			total_objects = 0
			total_errors = 0
			docs_with_text = 0
			new_obj = []
			old_objs_hash = {}
			largest_remaining_size = 0
			while !done do
				objs = reindexed_core.get_text_fields_in_archive(archive, page, size)
				total_objects += objs.length
				new_obj += objs
				#puts "new_obj.length=#{objs.length}"
				old_objs = old_core.get_text_fields_in_archive(archive, page, size)
				#puts "old_obj.length=#{old_objs.length}"
				page += 1
				if objs.length < size
					done = true
				end
				# first turn the old objects into a hash for quicker searching
				old_objs.each {|obj|
					uri = obj['uri']
					old_objs_hash[uri] = obj
				}
				# compare all the items in this set. We might not find all the same objects depending on what order we get them
				# back from solr, but we'll eliminate the ones we find, then get more.
				new_obj.each_with_index { |obj, i|
					uri = obj['uri']
					old_obj = old_objs_hash[uri]
					if old_obj != nil
						if old_obj['text'] == nil
							#old_text = ""
						elsif old_obj['text'].length > 1
							puts "#{uri} old text is an array of size #{old_obj['text'].length}"
							old_text = old_obj['text'].join(" | ").strip()
						else
							old_text = old_obj['text'][0].strip
						end
						if obj['text'] == nil
							if obj['has_full_text'] != false
								puts "#{uri} field has_full_text is #{obj['has_full_text']} but full text does not exist."
								total_errors += 1
							end
							if obj['is_ocr'] != nil
								puts "#{uri} field is_ocr exists and is #{obj['is_ocr']} but full text does not exist."
								total_errors += 1
							end
						elsif obj['text'].length > 1
							puts "#{uri} new text is an array of size #{obj['text'].length}"
								total_errors += 1
							text = obj['text'].join(" | ").strip()
						else
							docs_with_text += 1
							text = obj['text'][0].strip
							if obj['has_full_text'] == ((archive == "victbib") || (archive == "lilly") || (archive == "bancroft") || (archive == 'UVaPress_VLCS') || (archive == 'cbw') || (archive == 'whitbib') || (archive == 'uva_library'))	# this should be false for all archives except the specified ones.
								puts "#{uri} field has_full_text is #{obj['has_full_text']} but full text exists."
								total_errors += 1
							end
							if obj['is_ocr'] != false
								puts "#{uri} field is_ocr exists and is #{obj['is_ocr']} but full text exists."
								total_errors += 1
							end
						end
						if text == nil && old_text != nil
							puts "#{uri} text field has disappeared from the new index. (old text size = #{old_text.length})"
							total_errors += 1
						elsif text != nil && old_text == nil
							puts "#{uri} text field has appeared in the new index."
							total_errors += 1
						elsif text != old_text
							# delete extra spaces and blank lines and compare again
							text = text.gsub(" \n", "\n")
							old_text = old_text.gsub(" \n", "\n")
							text = text.gsub("\n ", "\n")
							old_text = old_text.gsub("\n ", "\n")
							text = text.gsub(" \n", "\n")
							old_text = old_text.gsub(" \n", "\n")
							text = text.gsub("\n ", "\n")
							old_text = old_text.gsub("\n ", "\n")
							text = text.gsub("\n\n", "\n")
							old_text = old_text.gsub("\n\n", "\n")
							text = text.gsub("\n\n", "\n")
							old_text = old_text.gsub("\n\n", "\n")

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
	#										name = "#{CollexEngine.archive_to_core_name(archive)}_#{total_errors}"
	#										File.open("#{RAILS_ROOT}/tmp/new/#{name}.txt", 'w') {|f| f.write(text) }
	#										File.open("#{RAILS_ROOT}/tmp/old/#{name}.txt", 'w') {|f| f.write(old_text) }
									print_start = first_mismatch - 1
									print_start = 0 if print_start < 0
									print "==== #{uri} mismatch at line #{first_mismatch}:\n(new #{new_arr.length})"
									print_end = first_mismatch + 1
									print_end = new_arr.length() -1 if print_end >= new_arr.length()
									print_start.upto(print_end) { |x|
										puts "\"#{new_arr[x]}\""
									}
									print "-- vs --\n(old #{new_arr.length})"
									print_end = first_mismatch + 1
									print_end = old_arr.length() -1 if print_end >= old_arr.length()
									print_start.upto(print_end) { |x|
										puts "\"#{old_arr[x]}\""
									}
									#puts "#{text}\n----\n#{old_text}"
									#puts "#{text}"
									total_errors += 1
								end
							end
						end
						new_obj[i] = nil	# we've done this one, so get rid of it
						old_objs_hash.delete(uri)
					end
				}
				new_obj = new_obj.compact()
				largest_remaining_size = new_obj.length if new_obj.length > largest_remaining_size
				largest_remaining_size = old_objs_hash.length if old_objs_hash.length > largest_remaining_size
			end

		# These are all the documents that didn't match anything in the old index.
		if new_obj.length > 0
			puts " ============================= TEXT ADDED TO ARCHIVE ==========================="
		end
		new_obj.each { |obj|
			puts "---------------------------------------------------------------------------------------------------------------"
			puts " --- #{ obj['uri']} ---"
			if obj['text']
				puts obj['text']
				total_errors += 1
			else
				puts " --- No full text for this item"
			end
			puts "---------------------------------------------------------------------------------------------------------------"
		}
		puts "    error: #{total_errors}; docs in archive: #{total_objects}; docs with text: #{docs_with_text}; largest remaining size: #{largest_remaining_size}; duration: #{Time.now-start_time} seconds."
		return total_objects, total_errors
	end

	def self.old_compare_text_one_archive(archive, reindexed_core, old_core)
		# this was used to compare the original, dirty text with the cleaned up text
			puts "====== Scanning archive \"#{archive}\"... ====== "
			start_time = Time.now
			done = false
			page = 0
			size = 10
			total_objects = 0
			total_errors = 0
			docs_with_text = 0
			new_obj = []
			old_objs_hash = {}
			largest_remaining_size = 0
			while !done do
				objs = reindexed_core.get_text_fields_in_archive(archive, page, size)
				total_objects += objs.length
				new_obj += objs
				#puts "new_obj.length=#{objs.length}"
				old_objs = old_core.get_text_fields_in_archive(archive, page, size)
				#puts "old_obj.length=#{old_objs.length}"
				page += 1
				if objs.length < size
					done = true
				end
				# first turn the old objects into a hash for quicker searching
				old_objs.each {|obj|
					uri = obj['uri']
					old_objs_hash[uri] = obj
				}
				# compare all the items in this set. We might not find all the same objects depending on what order we get them
				# back from solr, but we'll eliminate the ones we find, then get more.
				new_obj.each_with_index { |obj, i|
					uri = obj['uri']
					old_obj = old_objs_hash[uri]
					if old_obj != nil
						if old_obj['text'] == nil
							#old_text = ""
						elsif old_obj['text'].length > 1
							puts "#{uri} old text is an array of size #{old_obj['text'].length}"
							old_text = old_obj['text'].join(" | ").strip()
						else
							old_text = old_obj['text'][0].strip
						end
						if obj['text'] == nil
							if obj['has_full_text'] != false
								puts "#{uri} field has_full_text is #{obj['has_full_text']} but full text does not exist."
								total_errors += 1
							end
							if obj['is_ocr'] != nil
								puts "#{uri} field is_ocr exists and is #{obj['is_ocr']} but full text does not exist."
								total_errors += 1
							end
						elsif obj['text'].length > 1
							puts "#{uri} new text is an array of size #{obj['text'].length}"
								total_errors += 1
							text = obj['text'].join(" | ").strip()
						else
							docs_with_text += 1
							text = obj['text'][0].strip
							if obj['has_full_text'] == ((archive == "victbib") || (archive == "lilly") || (archive == "bancroft"))	# this should be false for all archives except the specified ones.
								puts "#{uri} field has_full_text is #{obj['has_full_text']} but full text exists."
								total_errors += 1
							end
							if obj['is_ocr'] != false
								puts "#{uri} field is_ocr exists and is #{obj['is_ocr']} but full text exists."
								total_errors += 1
							end
						end
						if text == nil && old_text != nil
							puts "#{uri} text field has disappeared from the new index. (old text size = #{old_text.length})"
							total_errors += 1
						elsif text != nil && old_text == nil
							puts "#{uri} text field has appeared in the new index."
							total_errors += 1
						elsif text != old_text
							# Get rid of all extra white space and extra lines. We first turn all white space except new lines into one white space.
							# then we know that all the remaining strings of more than one white space character must contain at least one newline.
							# so we can turn that into a single new line.
							old_text = old_text.gsub("&nbsp;", " ")	# TODO: remove after resource index is updated.
							text = text.gsub(/[ \t]+/, " ")
							old_text = old_text.gsub(/[ \t]+/, " ")
							text = text.gsub(/[\s]{2,}/, "\n")
							old_text = old_text.gsub(/[\s]{2,}/, "\n")
							# The old text had some imperfections that should be fixed now. TODO: remove this when the reference index is updated.
							# turn the old &amp; symbols into &
							old_text = old_text.gsub("&amp;", "&")
							old_text = old_text.gsub("&amp;", "&")
							old_text = old_text.gsub("&mdash;", "-")
							old_text = old_text.gsub("&copy;", "©")

							old_text = old_text.gsub("&mdash", "-")
							old_text = old_text.gsub("&ndash;", "-")
							old_text = old_text.gsub("&hyphen;", "-")
							old_text = old_text.gsub("&hyphen", "-")
							old_text = old_text.gsub("&colon", ":")
							old_text = old_text.gsub("&lsquo;", "‘")
							old_text = old_text.gsub("&rsquo;", "’")
							old_text = old_text.gsub("&ldquo;", "“")
							old_text = old_text.gsub("&rdquo;", "”")
							old_text = old_text.gsub("&eacute;", "é")
							old_text = old_text.gsub("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\"\n\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n", "")
							old_text = old_text.gsub("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\"\n\"http://www.w3.org/TR/html4/loose.dtd\">\n", "")
							old_text = old_text.gsub("<!DOCTYPE html PUBLIC \"-//W3C/DTD XHTML 1.1//EN\"\n\"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">\n", "")
							old_text = old_text.gsub("<!DOCTYPE html\"\n\"PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">\n", "")
							old_text = old_text.gsub("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"\n\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n", "")
							old_text = old_text.gsub("<!DOCTYPE html\n\"PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"\n", "")
							old_text = CGI.unescapeHTML(old_text)
							old_text = old_text.gsub(".page { padding: 1em;", "")
							old_text = old_text.gsub(" }\n", "")

							if archive == "PQCh-NCF" || archive == "PQCh-EAF"
								s = old_text.index('var contextRoot = ')
								if s
									e = old_text.index('value=openURL();', s)
									if s != nil && e != nil && s > 0 && e > 0
										old_text = old_text[0,s] + old_text[e+19..old_text.length-1]
									end
								end
							end

							if archive.index("muse") == 0
								text = text.gsub("\n0)", "\n")	# TODO: remove after replacing resources index.
								text = text.gsub("\n;\n", "\n")	# TODO: remove after replacing resources index.
								text = text.gsub("—", "-")
								text = text.gsub("–", "-")
								text = text.gsub("‐", "-")
								
								s = old_text.index('<link rel="search"')
								if s
									e = old_text.index('xml" />', s)
									if s != nil && e != nil && s > 0 && e > 0
										str1 = old_text[0,s]
										str2 = old_text[e+8..old_text.length-1]
										old_text = str1 + str2
									end
								end
								s = old_text.index('<!--')
								if s
									e = old_text.index('// -->', s)
									if s != nil && e != nil && s > 0 && e > 0
										old_text = old_text[0,s] + old_text[e+7..old_text.length-1]
									end
								end
								s = old_text.index('<!--')
								if s
									e = old_text.index('// -->', s)
									if s != nil && e != nil && s > 0 && e > 0
										old_text = old_text[0,s] + old_text[e+7..old_text.length-1]
									end
								end
								s = old_text.index('<!--')
								if s
									e = old_text.index('// -->', s)
									if s != nil && e != nil && s > 0 && e > 0
										old_text = old_text[0,s] + old_text[e+7..old_text.length-1]
									end
								end
								s = old_text.index('<BODY')
								if s
									e = old_text.index('>', s)
									if s != nil && e != nil && s > 0 && e > 0
										old_text = old_text[0,s] + old_text[e+2..old_text.length-1]
									end
								end
								s = old_text.index('<IMG')
								if s
									e = old_text.index('>', s)
									if s != nil && e != nil && s > 0 && e > 0
										old_text = old_text[0,s] + old_text[e+1..old_text.length-1]
									end
								end
								s = old_text.index('<img')
								if s
									e = old_text.index('>', s)
									if s != nil && e != nil && s > 0 && e > 0
										old_text = old_text[0,s] + old_text[e+1..old_text.length-1]
									end
								end

							elsif archive == "rc"
								s = old_text.index('<meta name="generator" content=')
								if s
									e = old_text.index('ascii" />', s)
									if s != nil && e != nil && s > 0 && e > 0
										str1 = old_text[0,s]
										str2 = old_text[e+10..old_text.length-1]
										old_text = str1 + str2
									end
								end
								s = old_text.index('<meta name="Description" content=')
								if s
									e = old_text.index('/>', s)
									if s != nil && e != nil && s > 0 && e > 0
										str1 = old_text[0,s]
										str2 = old_text[e+3..old_text.length-1]
										old_text = str1 + str2
									end
								end
								s = old_text.index('<meta name="keywords" content=')
								if s
									e = old_text.index('/>', s)
									if s != nil && e != nil && s > 0 && e > 0
										str1 = old_text[0,s]
										str2 = old_text[e+3..old_text.length-1]
										old_text = str1 + str2
									end
								end
								s = old_text.index('//<![CDATA[')
								if s
									e = old_text.index('"Romantic Circles" />', s)
									if s != nil && e != nil && s > 0 && e > 0
										str1 = old_text[0,s]
										str2 = old_text[e+21..old_text.length-1]
										old_text = str1 + str2
									end
								end
								s = old_text.index('<')
								if s
									e = old_text.index('>', s)
									if s != nil && e != nil && s > 0 && e > 0
										str1 = old_text[0,s]
										str2 = old_text[e+2..old_text.length-1]
										old_text = str1 + str2
									end
								end

							elsif archive == "swrp"
								old_text = old_text.gsub("</i> ", " ")
								s = old_text.index("var Url = {")
								e = old_text.index("dynamicLayout);")
								if s != nil && e != nil && s > 0 && e > 0
									old_text = old_text[0,s] + old_text[e+16..old_text.length-1]
								end
								s = old_text.index("function ShowStaticURL(urlAddress)")
								e = old_text.index("window.print();")
								if s != nil && e != nil && s > 0 && e > 0
									old_text = old_text[0,s] + old_text[e+18..old_text.length-1]
								end
								s = old_text.index("function ShowHideDiv(divid)")
								e = old_text.index("show metadata\";")
								if s != nil && e != nil && s > 0 && e > 0
									old_text = old_text[0,s] + old_text[e+19..old_text.length-1]
								end
								s = old_text.index("var gaJsHost =")
								e = old_text.index("catch(err) {}")
								if s != nil && e != nil && s > 0 && e > 0
									old_text = old_text[0,s] + old_text[e+12..old_text.length-1]
								end
								s = old_text.index('.title = "show metadata"')
								if s
									e = old_text.index('}', s)
									if s != nil && e != nil && s > 0 && e > 0
										str1 = old_text[0,s]
										str2 = old_text[e+2..old_text.length-1]
										old_text = str1 + str2
									end
								end

								old_text = old_text.sub("&raquo;", "»")
								old_text = old_text.sub("\n}", "")
								
							elsif archive == "victbib"
								old_text = old_text.gsub("<!-- bib: reslist.tpl\nModified by mdalmau, 10/29/2005-->\n", "")
							end
							if text != old_text
								text = trans_str(text)
								old_text = trans_str(old_text)
							end
							if text != old_text
								# TODO: The new text has a strange quirk that should be found: sometimes a particular unicode char appears twice.
#								s = String.new
#								c = 226
#								s << c
#								c = 128
#								s << c
#								c = 148
#								s << c
#								text = text.gsub(s+s, s)
#								old_text = old_text.gsub(s+s, s)
								if text != old_text
									old_arr = old_text.split("\n")
									new_arr = text.split("\n")
									first_mismatch = -1
									old_arr.each_with_index { |s, j|
										if first_mismatch == -1 && new_arr[j] != s
											skip = false
											if archive == "PQCh-NCF" || archive == "PQCh-EAF"
												skip = true if s.index("Do not export or print from this database without checking the Copyright Conditions to see what is permitted.") != nil && new_arr[j].index("Do not export or print from this database without checking the Copyright Conditions to see what is permitted.") != nil
												skip = true if s.index("Early American Fiction 1789-1875") != nil && new_arr[j].index("Early American Fiction 1789") != nil

											end

											if archive.index("muse") == 0
												skip = true if s.index("&") != nil	#TODO: temp: just ignore lines with char substitutions.
												if s.length > 9 && new_arr[j].length > 9
													slast = s[s.length-9..s.length-1]
													olast = new_arr[j]
													olast = olast[olast.length-9..olast.length-1]
													skip = true if s[0..8] == new_arr[j][0..8] || slast == olast
												end
											end
											if archive.index("swrp") == 0
												skip = true if s.index("All Works") == 0 && new_arr[j].index("All Works") == 0
												skip = true if s.index("Next ") == 0 && new_arr[j].index("Next ") == 0
												skip = true if s.index("Copyright") == 0 && new_arr[j].index("Copyright") == 0 && s.index("Terms of Use") != nil && new_arr[j].index("Terms of Use") != nil
												skip = true if s.index(" Previous") == 2 && new_arr[j].index(" Previous") == 1
												skip = "true" if s.index("}") != nil && new_arr[j] == nil
												new_arr.push("}") if s.index("}") != nil && new_arr[j] == nil
											end
											if !skip
												first_mismatch = j
											end
										end
									}
									if first_mismatch == -1	&& new_arr.length != old_arr.length # if the new text has more lines than the old text
										first_mismatch = old_arr.length
									end
									if first_mismatch != -1
										name = "#{CollexEngine.archive_to_core_name(archive)}_#{total_errors}"
										File.open("#{RAILS_ROOT}/tmp/new/#{name}.txt", 'w') {|f| f.write(text) }
										File.open("#{RAILS_ROOT}/tmp/old/#{name}.txt", 'w') {|f| f.write(old_text) }
										print_start = first_mismatch - 1
										print_start = 0 if print_start < 0
										print "==== #{uri} mismatch at line #{first_mismatch}:\n(new #{new_arr.length})"
										print_end = first_mismatch + 1
										print_end = new_arr.length() -1 if print_end >= new_arr.length()
										print_start.upto(print_end) { |x|
											puts "\"#{new_arr[x]}\""
										}
										print "-- vs --\n(old #{new_arr.length})"
										print_end = first_mismatch + 1
										print_end = old_arr.length() -1 if print_end >= old_arr.length()
										print_start.upto(print_end) { |x|
											puts "\"#{old_arr[x]}\""
										}
										#puts "#{text}\n----\n#{old_text}"
										#puts "#{text}"
										total_errors += 1
									end
								end
							end
						end
						new_obj[i] = nil	# we've done this one, so get rid of it
						old_objs_hash.delete(uri)
					end
				}
				new_obj = new_obj.compact()
				largest_remaining_size = new_obj.length if new_obj.length > largest_remaining_size
				largest_remaining_size = old_objs_hash.length if old_objs_hash.length > largest_remaining_size
			end

		# These are all the objects that didn't match.
		if new_obj.length > 0
			puts " ============================= TEXT ADDED TO ARCHIVE ==========================="
		end
		new_obj.each { |obj|
			puts "---------------------------------------------------------------------------------------------------------------"
			puts " --- #{ obj['uri']} ---"
			if obj['text']
				puts obj['text']
				total_errors += 1
			else
				puts " --- No full text for this item"
			end
			puts "---------------------------------------------------------------------------------------------------------------"
		}
		puts "    error: #{total_errors}; docs in archive: #{total_objects}; docs with text: #{docs_with_text}; largest remaining size: #{largest_remaining_size}; duration: #{Time.now-start_time} seconds."
		return total_objects, total_errors
	end

	public
	def self.compare_reindexed_core_text(params)
		archive_to_scan = params[:archive]
		start_after = params[:start_after]
		use_merged_index = params[:use_merged_index]
		resources = CollexEngine.new(['resources'])
		total_docs_scanned = 0
		total_errors = 0

		if archive_to_scan
			if use_merged_index
				reindexed = CollexEngine.new(["merged"])
			else
				core_name = archive_to_core_name(archive_to_scan)
				reindexed = CollexEngine.new(["archive_#{core_name}"])
			end
			total_docs_scanned, total_errors = compare_text_one_archive(archive_to_scan, reindexed, resources)
		else
			archives = resources.get_all_archives()
			started = start_after == nil
			archives.each {|archive|
				if archive.index("exhibit_") == 0
					puts "====== Skipping #{archive}."
				elsif started
					if use_merged_index
						reindexed = CollexEngine.new(["merged"])
					else
						core_name = archive_to_core_name(archive)
						reindexed = CollexEngine.new(["archive_#{core_name}"])
					end
					scanned, errors = compare_text_one_archive(archive, reindexed, resources)
					total_docs_scanned += scanned
					total_errors += errors
				else
					if archive == start_after
						started = true
					end
				end
			}
		end
		puts "Total Docs Scanned: #{total_docs_scanned}. Total Errors: #{total_errors}. Total Docs in index: #{resources.num_docs()}"
	end

	public	# these should actually be some sort of private since they are only called inside this file.
	def self.archive_to_core_name(archive)
		return archive.gsub(":", "_").gsub(" ", "_").gsub(",", "_").gsub("-", "_")
	end

	public
	# This looks at the production uri's and compares them to the reindex uri's and prints out the missing ones.
	def self.get_list_of_skipped_objects(params)
		use_merged_index = params[:use_merged_index]
		archive_to_scan = params[:archive]
		resources = CollexEngine.new(['resources'])
		archives = resources.get_all_archives()
		num_not_indexed = 0
		num_new = 0
		archives.each {|archive|
			if (archive_to_scan == nil || archive_to_scan == archive)
				print "====== Scanning archive \"#{archive}\"... ====== "
				if use_merged_index
					reindexed = CollexEngine.new(["merged"])
				else
					core_name = archive_to_core_name(archive)
					reindexed = CollexEngine.new(["archive_#{core_name}"])
				end
				begin
					new_obj = reindexed.get_all_uris_in_archive(archive)
				rescue
					new_obj = []
				end
				print "retrieved #{new_obj.length} new objects..."
				old_obj = resources.get_all_uris_in_archive(archive)
				puts "retrieved #{old_obj.length} old objects..."
				uris = {}
				new_obj.each{|obj|
					uris[obj['uri']] = 'new'
				}
				old_obj.each{|obj|
					if uris[obj['uri']] != nil	# found in both the old and new indexes
						uris.delete(obj['uri'])
					else
						uris[obj['uri']] = 'old'
					end
				}

				old_only = []
				new_only = []
				uris.each { |uri, status|
					if status == 'old'
						old_only.push(uri)
					elsif status == 'new'
						new_only.push(uri)
					end
				}
				old_only = old_only.sort()
				new_only = new_only.sort()

				num_not_indexed += old_only.length
				old_only.each { |uri|
					puts "    Old: #{uri}"
				}
				num_new += new_only.length
				new_only.each { |uri|
					puts "    New: #{uri}"
				}
			end
		}	# each archive


		puts "Total not indexed: #{num_not_indexed}. Total new: #{num_new}. Total Docs in index: #{resources.num_docs()}"
	end

	def optimize()
		@solr.optimize() #(:wait_searcher => true, :wait_flush => true)
  end

private
	def self.print_error(uri, total_errors, first_error, msg)
		puts "---#{uri}---" if first_error
		total_errors += 1
		first_error = false
		puts "    " + msg
		return total_errors, first_error
	end

  # splits constraints into a full-text query (for relevancy ranking) and filter queries for constraining
  def solrize_constraints(constraints)
    queries = []
    filter_queries = []
		#filter_queries << 'title_sort:t*'
    constraints.each do |constraint|
      if constraint.is_a?(ExpressionConstraint)
        queries << constraint.to_solr_expression
      else
        filter_queries << constraint.to_solr_expression
      end
    end
    queries << "*:*" if queries.empty?

    [queries.join(" AND "), filter_queries]
  end

  def facets_to_hash(facet_data)
    # TODO: change how <unspecified> is dealt with, so that it can link back to a -field:[* TO *] query.
    #       Leave nil as-is here, let the UI deal with rendering it as <unspecified>
    facets = {}
    facet_data.each do |facet,values|
      facets[facet] = {}
      Solr::Util.paired_array_each(values) do |key, value|
        # despite requesting mincount => 1, nil (aka "<unspecified>") items can be returned with zero count anyway
        facets[facet][key || "<unspecified>"] = value if value > 0
      end
    end
    facets
  end

#  def objects_for_uris(uris, username=nil)
#    #TODO allow paging through rows
#
#    query = uris.collect {|uri| "uri:#{Solr::Util.query_parser_escape(uri)}"}.join(" OR ")
#    # TODO: generalize the field list here
#    field_list = ["archive","date_label","genre","role_ART", "role_AUT", "role_EDT", "role_PBL", "role_TRL","source","thumbnail","title","alternative","uri","url", "username"]
#    if username
#      field_list << "#{username}_tag"
#      field_list << "#{username}_annotation"
#    end
#    req = Solr::Request::Standard.new(
#             :start => 0, :rows => 500,
#             :query => query, :field_list => field_list)
#
#    response = @solr.send(req)
#    response.hits
#  end
#
#  def connection
#    @solr
#  end

#  def all_facets
#    # TODO!!!
#    # this is only used from the stats controller.  it needs to be ported to using Solr's Standard request, instead of the
#    # now removed FacetRequest
#    @solr.send(FacetRequest.new).all_facets
#  end

#  def agent_suggest(constraints, prefix)	# useful for auto complete on author, etc. fields.
#    query, filter_queries = solrize_constraints(constraints)
#
#    # case insensitive, replace commas, semicolons, and periods with spaces
#    raw_query_string = prefix.downcase.sub(/[,;.]/," ")
#
#    # each word in the query is a seperate name
#    names = raw_query_string.split(" ")
#
#    req = Solr::Request::Standard.new(
#            :start => 0, :rows => 0,
#            :query => "#{query} AND (#{name_query_string(names)})", :filter_queries => filter_queries,
#            :facets => {:fields => ["role_ART", "role_AUT", "role_EDT", "role_PBL", "role_TRL"], :mincount => 1, :limit => -1})
#
#    response = @solr.send(req)
#    facets = facets_to_hash(response.data['facet_counts']['facet_fields'])
#    agents = {}
#    hits = []
#    facets.each do |role_with_prefix, role_data|
#      role = role_with_prefix[-3,3]
#      role_data.each do |name,freq|
#        names.each_index do |i|
#
#         if name.downcase.starts_with?(names[i])
#           # count this as a match
#           role_counts = agents[name] ||= {}
#           role_counts[role] ||= 0
#           role_counts[role] = role_counts[role] + freq
#         end
#        end
#      end
#    end
#
#    retval = []
#    agents.each do |name, roles|
#      retval << {:name => name, :roles => roles, :total => roles.values.inject(0) {|total,val| total + val}}
#    end
#    retval.sort {|a,b| b[:total] <=> a[:total]}
#  end

#  def indexed?(uri)
#    query = "uri:#{Solr::Util.query_parser_escape(uri)}"
#    req = Solr::Request::Standard.new(:start => 0, :rows => 1, :query => query)
#    response = @solr.send(req)
#    response.hits[0] != nil
#  end
  
#  def object_detail(objid, username=nil)	#called by SolrResource.find_by_uri
#    query = "uri:#{Solr::Util.query_parser_escape(objid)}"
#    # TODO: generalize the field list here
#    field_list = ["archive","date_label","genre","role_ART", "role_AUT", "role_EDT", "role_PBL", "role_TRL","source","thumbnail","image","title","alternative","uri","url", "username"]
#    # TODO: tag is not currently stored, but to store it requires some strange contortions in #add_collectables currently
#    # however, to get tags, you could facet on the tag field
#    # field_list << 'tag'
#    if username
#      field_list << "#{username}_tag"
#      field_list << "#{username}_annotation"
#    end
#    req = Solr::Request::Standard.new(
#             :start => 0, :rows => 1,
#             :query => query, :field_list => field_list,
#             :mlt => {:count => 3, :field_list => ["title", "genre", "agent", "year", "text","tag"], :min_term_freq => 1})
#
#    response = @solr.send(req)
#
#    document = response.hits[0]
#    mlt = response.data['moreLikeThis'][objid]['docs'] rescue []
#    collection_info = username ? {'users' => document['username'] || []} : nil  rescue nil
#
#    [document, mlt, collection_info]
#  end
  
#  def objects_behind_urls(urls, username=nil)
#    #TODO allow paging through rows
#    query = urls.collect {|url| "url:#{Solr::Util.query_parser_escape(url)}"}.join(" OR ")
#    # TODO: generalize the field list here
#    field_list = ["archive","date_label","genre","role_ART", "role_AUT", "role_EDT", "role_PBL", "role_TRL","source","thumbnail","title","alternative","uri","url", "username"]
#    if username
#      field_list << "#{username}_tag"
#      field_list << "#{username}_annotation"
#    end
#    req = Solr::Request::Standard.new(
#             :start => 0, :rows => 500,
#             :query => query, :field_list => field_list)
#
#    response = @solr.send(req)
#    response.hits
#  end
  
  # Modifies or adds a document to Solr index. Currently only handles uri/tags/comments
#  def add_collectables(username, collectables)
#    collectables.each do |uri, info|
#      tags = info[:tags]
#      annotation = info[:annotation]
#
#      req = Solr::Request::ModifyDocument.new(
#          :uri => uri,
#          :overwrite => {"#{username}_annotation" => annotation,
#                         "#{username}_tag" => tags,
#                        },
#          :distinct => {:username => username})
#      @solr.send(req)
#    end
#  end
#
#  def update_collectables(username, uri, tags, annotation)
#    add_collectables(username, {uri => {:tags => tags, :annotation => annotation}})
#  end
#
#  def remove_collectables(username, uri)
#    req = Solr::Request::ModifyDocument.new(
#        :uri => uri,
#        :overwrite => {"#{username}_annotation" => nil,
#                       "#{username}_tag" => nil,
#                      },
#        :delete => {:username => username})
#    @solr.send(req)
#  end
  
#  def optimize
#    @solr.optimize
#  end
#
#  def commit
#    @solr.commit(:wait_searcher => false, :wait_flush => false)
#  end
#
#  def name_query_string( names )
#    # search on each name in the query
#    query_string = ""
#    names.each_index { |i|
#      last = (names.size-1 == i)
#      and_string = last ? "" : " AND "
#      # example: agent:gabriel* AND agent:dante* AND agent:rossetti*
#      query_string << "agent:#{names[i]}*#{and_string}"
#    }
#
#    # return the accumulated query string and the names in it
#    return query_string
#  end
end
