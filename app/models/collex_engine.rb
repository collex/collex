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

require 'rsolr'
# documentation at: http://github.com/mwmitchell/rsolr

class CollexEngine
	CORE = [ "resources" ]
	@@report_file = nil
	@@report_file_prefix = nil
	
  def initialize(cores=CORE)
    @num_docs = -1
		@cores = []
		prefix = SOLR_URL.slice(7..SOLR_URL.length)	# this removes the "http://" part
		cores.each {|core|
			@cores.push("#{prefix}/#{core}")
		}

	@solr = RSolr.connect( :url=>"#{SOLR_URL}/#{cores[0]}" )
		@field_list = [ "uri", "archive", "date_label", "genre", "source", "image", "thumbnail", "title", "alternative", "url",
			"role_ART", "role_AUT", "role_EDT", "role_PBL", "role_TRL", "role_EGR", "role_ETR", "role_CRE", "freeculture",
			"is_ocr", "federation", "has_full_text", "source_xml", 'typewright' ]
    @all_fields_except_text = @field_list + [ "publisher", "agent", "agent_facet", "author", "batch", "editor",
			"text_url", "year", "type", "date_updated", "title_sort", "author_sort", "year_sort", "source_html", "source_sgml", "person", "format", "language", "geospacial" ]
		@facet_fields = ['genre','archive','freeculture', 'has_full_text', 'federation', 'typewright']
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

	def solr_select(options)
		if options[:field_list]
			options[:fl] = options[:field_list].join(' ')
			options[:field_list] = nil
		end
		if options[:facets]
			options[:facet] = true
			options["facet.field"] = options[:facets][:fields]
			options["facet.prefix"] = options[:facets][:prefix]
			options["facet.missing"] = options[:facets][:missing]
			options["facet.method"] = options[:facets][:method]
			options["facet.mincount"] = 1
			options["facet.limit"] = -1
			options[:facets] = nil
		end
		if options[:highlighting]
			options['hl.fl'] = options[:highlighting][:field_list]
			options['hl.fragsize'] = options[:highlighting][:fragment_size]
			options['hl'] = true
			# Increase this value to allow multiple snippets to 
			# be returned from the same document
			options['f.text.hl.snippets'] = 1
			options['hl.useFastVectorHighlighter'] = true
			options[:highlighting] = nil
		end
		options['version'] = '2.2'
		options['defType'] = 'dismax'
		
		# dismax parser does not understand wildacrd syntax!
		# when encountered, clear out the q opt and push
		# it to the q.alt opt. this string will be parsed
		# by the standard query parser which does handle wildcards.
		# Source: http://wiki.apache.org/solr/DisMaxQParserPlugin#q.alt.
		if options[:q] == "*:*"
		  options[:q] = ""
		  options['q.alt'] = "*:*" 
		end
		
		# We don't need to use shards if there is only one index
		if options[:shards]
			if options[:shards].length == 1
				options[:shards] = nil
			else
				options[:shards] = options[:shards].join(',') 
			end
		end
#		return @solr.select(:params => options)
		ret = @solr.post( 'select', :data => options )

		# correct the character set for all fields
		if ret && ret['response'] && ret['response']['docs']
			ret['response']['docs'].each { |doc|
				doc.each { |k,v|
					if v.kind_of?(String)
						doc[k] = v.force_encoding("UTF-8")
					elsif v.kind_of?(Array)
						v.each_with_index { |str, i|
							if str.kind_of?(String)
								v[i] = str.force_encoding("UTF-8")
							end
						}
					end
				}
			}
		end
		# highlighting is returned as a hash of uri to a hash that is either empty or contains 'text' => Array of one string element.
		# simplify this to return either nil or a string.
		if ret && ret['highlighting']
			ret['highlighting'].each { |uri,hsh|
				if hsh.length == 0 || hsh['text'] == nil || hsh['text'].length == 0
					ret['highlighting'][uri] = nil
				else
					str = hsh['text'].join("\n") # This should always return an array of size 1, but just in case, we won't throw away any items.
					ret['highlighting'][uri] = str.force_encoding("UTF-8")
				end
			}
		end
		return ret
	end

	def query_num_docs()
		response = solr_select(:q=>"*:*", :fq=>"federation:#{DEFAULT_FEDERATION}", :rows => 1, :facets => {:fields => 'archive', :mincount => 1, :missing => true, :limit => -1}, :shards => @cores)
		archive_num = 0
		if response && response['facet_counts'] && response['facet_counts']['facet_fields'] && response['facet_counts']['facet_fields']['archive']
			facets = response['facet_counts']['facet_fields']['archive']
			skip_next = false
			facets.each {|f|
				if f.kind_of?(Fixnum) && f.to_i > 0 && skip_next == false
					archive_num = archive_num + 1
				elsif f.kind_of?(String) && f.include?('exhibit_')
					skip_next = true
				else
					skip_next = false
				end
			}
		end
		return { :total => response['response']['numFound'], :sites => archive_num }
	end

	def warm_num_doc_cache()
		if @num_docs == -1 || @num_sites == -1
			begin
				File.open("#{Rails.root}/cache/num_docs.txt", "r") { |f|
					str = f.read
					arr = str.split(',')
					if arr == 2
						@num_docs = arr[0].to_i
						@num_sites = arr[1].to_i
					end
				}
			rescue
			end
			if @num_docs <= 0
				ret = query_num_docs()
				@num_docs = ret[:total]
				@num_sites = ret[:sites]
				File.open("#{Rails.root}/cache/num_docs.txt", 'w') {|f| f.write("#{@num_docs},#{@num_sites}") }
			end
		end
	end

  def num_docs	# called for each entry point to get the number for the footer.
    warm_num_doc_cache()
    return @num_docs
  end

  def num_sites	# called for each entry point to get the number for the footer.
    warm_num_doc_cache()
    return @num_sites
  end

  def auto_complete(facet, constraints, prefix)	# called for autocomplete
    query, filter_queries = solrize_constraints(constraints)
	response = solr_select(:start => 0, :rows => 0, :shards => @cores,
            :q => query, :fq => filter_queries,
            :facets => {:fields => [facet], :mincount => 1, :missing => false, :limit => -1, :prefix => prefix, :method => 'enum'})
    facets_to_hash(response['facet_counts']['facet_fields'])[facet]
  end
  
	def name_facet(constraints)	# called when the "Click here to see the top authors..." is clicked
		query, filter_queries = solrize_constraints(constraints)
		response = solr_select(:start => 0, :rows => 0,
					:q => query, :fq => filter_queries,
					:field_list => [ 'role_AUT', 'role_EDT', 'role_PBL'],
					:facets => {:fields => [ 'role_AUT', 'role_EDT', 'role_PBL'], :mincount => 1, :missing => false, :limit => -1},
					:shards => @cores)

		facets = response['facet_counts']['facet_fields']
		facets = facets_to_hash(facets)
		facets2 = {}
		facets.each { |ty, facet|
			facets2[ty] = facet.sort { |a,b| (a[1] == b[1]) ? a[0] <=> b[0] : b[1] <=> a[1] }
		}

		return facets2
	end

	def search_user_content(options)
		# input parameters:
		facet_exhibit = options[:facet][:exhibit]	# bool
		facet_cluster = options[:facet][:cluster]	# bool
		facet_group = options[:facet][:group]	# bool
		facet_comment = options[:facet][:comment]	# bool
		facet_federation = options[:facet][:federation]	#bool
		facet_section = options[:facet][:section]	# symbol -- enum: classroom|community|peer-reviewed
		member = options[:member]	# array of group
		admin = options[:admin]	# array of group
		search_terms = options[:terms]	# array of strings, they are ANDed
		sort_by = options[:sort_by]	# symbol -- enum: relevancy|title_sort|last_modified
		page = options[:page]	# int
		page_size = options[:page_size]	#int
		facet_group_id = options[:facet][:group_id]	# int

		query = "federation:#{facet_federation} AND section:#{facet_section}"
		if search_terms != nil
			# get rid of special symbols
			search_terms = search_terms.gsub(/\W/, ' ')
			arr = search_terms.split(' ')
			arr.each {|term|
				query += " AND content:#{term}"
			}
		end

		group_members = ""
		member.each {|ar|
			group_members += " OR visible_to_group_member:#{ar.id}"
		}

		group_admins = ""
		admin.each {|ar|
			group_admins += " OR visible_to_group_admin:#{ar.id}"
		}
		query += " AND (visible_to_everyone:true #{group_members} #{group_admins})"
		if facet_group_id
			query += " AND group_id:#{facet_group_id}"
		end

		arr = []
		arr.push("object_type:Exhibit") if facet_exhibit
		arr.push("object_type:Cluster") if facet_cluster
		arr.push("object_type:Group") if facet_group
		arr.push("object_type:DiscussionThread") if facet_comment
		all_query = query
		if arr.length > 0
			query += " AND ( #{arr.join(' OR ')})"
		end
		
		ActiveRecord::Base.logger.info("*** USER QUERY: #{query}")
		case sort_by
		when :relevancy then sort = nil
		when :title_sort then sort = "#{sort_by.to_s} asc"
		when :last_modified then sort = "#{sort_by.to_s} desc"
		end

		response = solr_select(:start => page*page_size, :rows => page_size, :sort => sort,
						'q.alt' => query,
						:field_list => [ 'key', 'object_type', 'object_id', 'last_modified' ],
						:highlighting => {:field_list => ['text'], :fragment_size => 200, :max_analyzed_chars => 100 })

		response_total = solr_select(:start => 1, :rows => 1, :q => all_query,
						:field_list => [ 'key', 'object_type', 'object_id', 'last_modified' ])

		results = { :total => response_total['response']['numFound'], :total_hits => response['response']['numFound'], :hits => response['response']['docs'] }
		# add the highlighting to the object
		if response['highlighting'] && search_terms != nil
			highlight = response['highlighting']
			results[:hits].each  {|hit|
				this_highlight = highlight[hit['key']]
				hit['text'] = this_highlight if this_highlight && this_highlight['text']
			}
		end
		# the time is a string formatted as: 1995-12-31T23:59:59Z or 1995-12-31T23:59:59.999Z
		results[:hits].each  {|hit|
			dt = hit['last_modified'].split('T')
			hit['last_modified'] = nil	# in case it wasn't a valid time below.
			if dt.length == 2
				dat = dt[0].split('-')
				tim = dt[1].split(':')
				if dat.length == 3 && tim.length > 2
					t = Time.gm(dat[0], dat[1], dat[2], tim[0], tim[1])
					hit['last_modified'] = t
				end
			end
		}
return results
	end

  # Search SOLR for documents matching the constraints.
  #
  def search(constraints, start, max, sort_by, sort_ascending)	
    
    # turn map of constraint data into solr quert strings
    query, filter_queries = solrize_constraints(constraints)
		
	  # this is the full search. We want sorting, highlighting and non-citation links preferred
	  if sort_ascending
      sort_param = sort_by ? "#{sort_by} asc" : nil
    else
      sort_param = sort_by ? "#{sort_by} desc" : nil
    end
    
    hl_opts = nil
    bq_opts = nil
    if query != '*:*'
      hl_opts = {:field_list => ['text'], :fragment_size => 600 }
      bq_opts = '-genre:Citation^5'
    end
      		
		response = solr_select(:start => start, :rows => max, :sort => sort_param,
					:q => query, :fq => filter_queries,
					:bq => bq_opts,
					:field_list => @field_list,
					:facets => {:fields => @facet_fields, :mincount => 1, :missing => true, :limit => -1},
					:highlighting => hl_opts, :shards => @cores)
  
    results = {}
    results["total_hits"] = response['response']['numFound']
    results["hits"] = response['response']['docs']

    # Reformat the facets into what the UI wants, so as to leave that code as-is for now
    results["facets"] = facets_to_hash(response['facet_counts']['facet_fields'])
    results["highlighting"] = response['highlighting']
    
    # append the total for the other federation 
    results = append_archive_counts(constraints, results)
  	return append_federation_counts(constraints, results)

  end
  
  # get a list of all availble resources in solr
  #
  def get_resource_list()  
   
    response = solr_select(:start => 1, :rows => 10, 
          :q => "*:*", 
          :field_list => @field_list,
          :facets => {:fields => @facet_fields, :mincount => 1, :missing => true, :limit => -1},
          :shards => @cores)
  
    results = {}
    results["facets"] = facets_to_hash(response['facet_counts']['facet_fields'])
    return results['facets']['archive']
  end
  
  private 
  def append_archive_counts(src_constraints, prior_results)  
    
    # trim out any archive constraints. TO get counts, we want them all
    constraints = []
    src_constraints.each { |constraint| constraints.push(constraint) }
    constraints.delete_if { |constraint| constraint.is_a?(FacetConstraint) && constraint[:fieldx] == 'archive' }
    if constraints.length == src_constraints.length
      return prior_results
    end
    
    # turn map of constraint data into solr quert strings
    query, filter_queries = solrize_constraints(constraints)
    
    # do a very basic search and return minimal info
    response = solr_select(:q => query, :fq => filter_queries,
      :field_list => ['uri'],
      :facets => {:fields => @facet_fields, :mincount => 1, :missing => true, :limit => -1}, 
      :shards => @cores )

    # Reformat the facets into what the UI wants, so as to leave that code as-is for now
    # tack the new federaton info into the orignal results map
    results = {}
    results["facets"] = facets_to_hash(response['facet_counts']['facet_fields'])
    prior_results['facets']['archive'] = results['facets']['archive']
    return prior_results
  end
  
  private 
  def append_federation_counts(src_constraints, prior_results)  
    
    # trim out any federation constraints. TO get counts, we want them all
    constraints = []
    src_constraints.each { |constraint| constraints.push(constraint) }
    constraints.delete_if { |constraint| constraint.is_a?(FederationConstraint) }
    if constraints.length == src_constraints.length
      return prior_results
    end
    
    # turn map of constraint data into solr quert strings
    query, filter_queries = solrize_constraints(constraints)
    
    # do a very basic search and return minimal info
    response = solr_select(:q => query, :fq => filter_queries,
      :field_list => ['uri'],
      :facets => {:fields => @facet_fields, :mincount => 1, :missing => true, :limit => -1}, 
      :shards => @cores )

    # Reformat the facets into what the UI wants, so as to leave that code as-is for now
    # tack the new federaton info into the orignal results map
    results = {}
    results["facets"] = facets_to_hash(response['facet_counts']['facet_fields'])
    prior_results['facets']['federation'] = results['facets']['federation']
    return prior_results
  end
  
  public 
	def get_object(uri, all_fields = false) #called when "collect" is pressed.
		# Returns nil if the object doesn't exist, or the object if it does.
		query = "uri:#{CollexEngine.query_parser_escape(uri)}"
		if all_fields == true
			field_list = @all_fields_except_text
		else
			field_list = @field_list
		end

		response = solr_select(:start => 0, :rows => 1,
             'q.alt' => query, :field_list => field_list, :shards => @cores)
		if response['response']['docs'].length > 0
#			fix_free_culture(response['response']['docs'][0])
	    return response['response']['docs'][0]
		end
		return nil
	end

	def get_object_with_text(uri)
		# Returns nil if the object doesn't exist, or the object if it does.
		query = "uri:#{CollexEngine.query_parser_escape(uri)}"

		response = solr_select(:start => 0, :rows => 1,
			'q.alt' => query, :shards => @cores)
		return response['response']['docs'][0] if response['response']['docs'].length > 0
		return nil
	end

	def add_object(fields, relevancy = nil, is_retry = false) # called by Exhibit to index exhibits
		# this takes a hash that contains a set of fields expressed as symbols, i.e. { :uri => 'something' }
#		doc = Solr::Document.new(fields)
#		doc.boost = relevancy if relevancy != nil
#		@solr.add(doc)
		begin
			if relevancy
				@solr.add(fields) do |doc|
					doc.attrs[:boost] = relevancy # boost the document
				end
				add_xml = @solr.xml.add(fields, {}) do |doc|
					doc.attrs[:boost] = relevancy
				end
				@solr.update(:data => add_xml)
			else
				@solr.add(fields)
			end
		rescue Exception => e
			CollexEngine.report_line("ADD OBJECT: Continuing after exception: #{e}\n")
			CollexEngine.report_line("URI: #{fields['uri']}\n")
			CollexEngine.report_line("#{fields.to_s}\n")
			add_object(fields, relevancy, true) if is_retry == false
		end
	end

	def commit()	# called by Exhibit at the end of indexing exhibits
		@solr.commit() # :wait_searcher => false, :wait_flush => false, :shards => @cores)
	end

	def delete_archive(archive) #usually called when un-peer-reviewing an exhibit, but is also used for indexing.
		# Warning: This will delete all the documents in the archive!
		@solr.delete_by_query "+archive:#{archive.gsub(":", "\\:").gsub(' ', '\ ')}"
	end

	#
	# Simple utils from solr-ruby
	#

	# paired_array_each([key1,value1,key2,value2]) yields twice:
	#     |key1,value1|  and |key2,value2|
	def self.paired_array_each(a, &block)
		0.upto(a.size / 2 - 1) do |i|
			n = i * 2
			yield(a[n], a[n+1])
		end
	end

	def self.query_parser_escape(string)
		# backslash prefix everything that isn't a word character
		string.gsub(/(\W)/,'\\\\\1')
	end
#
# Everything below this point is for indexing and testing indexes.
#

#	def remove_object(uri)
#		@solr.delete(uri)
#	end
	def self.set_report_file(fname)
		@@report_file = fname
		begin
			File.delete(fname)
		rescue
		end
		@@report_file_prefix = "Started: #{Time.now}"	# We want the file to be empty unless something important is reported, so delay writing this until the first log message
	end

	def self.report_line_if(str)
		# This only prints the line if the file is empty
		if @@report_file_prefix == nil
			self.report_line(str)
		else
			puts str
		end
	end

	def self.report_line(str)
		if @@report_file
			open(@@report_file, 'a') { |f|
				if @@report_file_prefix
					f.puts @@report_file_prefix
					@@report_file_prefix = nil
				end
				begin
					#f.puts str.encoding.name
					f.puts str
				rescue Exception => e
					f.puts("Continuing after exception: #{e}\n")
					bytes = ''
					str.each_byte { |b|
						bytes += "#{b} "
					}
					f.puts bytes
				end
			}
		end
		begin
			puts str
		rescue Exception => e
			f.puts("Continuing after exception: #{e}\n")
			bytes = ''
			str.each_byte { |b|
				bytes += "#{b} "
			}
			f.puts bytes
		end
	end

	def replace_archive(archive)
		arr = @cores[0].split('/')
		core = arr[arr.length-1]
		url = "#{SOLR_URL}/admin/cores?action=mergeindexes&core=#{core}"
		url += "&indexDir=#{archive}"
		CollexEngine.report_line("curl \"#{url}\"\n")
		CollexEngine.report_line(`curl \"#{url}\"`)
			# this will timeout. Don't crash when that happens.
		begin
			@solr.optimize()
		rescue
		end
	end

	def replace_archives(archives)
		arr = @cores[0].split('/')
		core = arr[arr.length-1]
		url = "#{SOLR_URL}/admin/cores?action=mergeindexes&core=#{core}"
		archives.each {|archive|
			url += "&indexDir=#{archive}"
		}
		CollexEngine.report_line("curl \"#{url}\"\n")
		begin
			# this will timeout. Don't crash when that happens.
			CollexEngine.report_line(`curl \"#{url}\"`)
		rescue Exception => e
			CollexEngine.report_line("Continuing after exception: #{e}\n")
		end
		begin
			@solr.optimize()
		rescue
			CollexEngine.report_line("Continuing after exception: #{e}\n")
		end
	end

	# this merges the indexes passed into the current index
	def merge(indexes)
		arr = @cores[0].split('/')
		core = arr[arr.length-1]
		url = "#{SOLR_URL}/admin/cores?action=mergeindexes&core=#{core}"
		indexes.each{|index|
				url += "&indexDir=solr/data/#{index}/index"
		}
		CollexEngine.report_line("curl \"#{url}\"\n")
		CollexEngine.report_line(`curl \"#{url}\"`)

		# this will timeout. Don't crash when that happens.
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

		CollexEngine.report_line("curl \"#{url}\"\n")
		CollexEngine.report_line(`curl \"#{url}\"`)
	end

	private
	def get_page_in_archive(archive, page, size, field_list)
    query = "archive:#{CollexEngine.query_parser_escape(archive)}"

	  response = solr_select(:start => page*size, :rows => size,	:sort => "uri asc",
             :q => query, :field_list => field_list)
    return response['response']['docs']
	end

  public
  def get_all_archives
    results = search([], 1, 10, nil, true)
    found_resources = results['facets']['archive']
    resources = []
    found_resources.each {|key,val| resources.push(key)}
    return resources.sort()
  end

  private
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

  private
	def get_text_fields_in_archive(archive, page, size)
		return get_page_in_archive(archive, page, size, [ 'uri', 'text', 'is_ocr', 'has_full_text' ])
 	end

  private
	def get_all_uris_in_archive(archive)
		return get_all_in_archive(archive, [ "uri" ])
	end

  public
	def get_all_objects_in_archive(archive)
		return get_all_in_archive(archive, @all_fields_except_text)
	end

  public
	def get_all_objects_in_archive_with_text(archive)
		fields = @all_fields_except_text + [ 'text' ]
		return get_all_in_archive(archive, fields)
	end

	public
	# Warning: This will completely wipe out the index. Just do this on the reindexing resource!
	def start_reindex
		@solr.delete_by_query "*:*"
	end

	def clear_index
	  begin
  		@solr.delete_by_query "*:*"
  		@solr.optimize
  		ok = true
  	 rescue Exception => e
      raise e if e.message.index("404 Not Found").nil?
    end
	end

	# public	# these should actually be some sort of private since they are only called inside this file.
	# def self.compare_object_arrays(new_objs, old_objs, total_errors)
		# # first turn the old objects into a hash for quicker searching
		# old_hash = {}
		# old_objs.each {|obj|
			# uri = obj['uri']
			# old_hash[uri] = obj
		# }
# 
		# # now go through each item one by one and compare them.
		# new_objs.each {|new_obj|
			# uri = new_obj['uri']
			# old_obj = old_hash[uri]
			# total_errors, err_arr = CompareSolrObject.compare_objs(new_obj, old_obj, total_errors)
			# err_arr.each { |err| CollexEngine.report_line(err) }
		# }
# 
		# return total_errors
	# end

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

	# public
	# def self.create_old_archive_name(archive)
		# old_archive = archive
		# return old_archive
	# end

	# def self.compare_reindexed_core(params)
		# archive_to_scan = params[:archive]
		# CollexEngine.set_report_file(params[:log])
		# resources = CollexEngine.new(['resources'])
		# total_docs_scanned = 0
		# total_errors = 0
# 
		# old_archive = self.create_old_archive_name(archive_to_scan)
		# str = archive_to_scan
		# str += '/' + old_archive if old_archive != archive_to_scan
		# CollexEngine.report_line("====== Scanning archive \"#{str}\"... ====== ")
		# reindexed = CollexEngine.new(["archive_#{archive_to_core_name(archive_to_scan)}"])
# 
		# new_obj = reindexed.get_all_objects_in_archive(archive_to_scan)
		# CollexEngine.report_line("retrieved #{new_obj.length} new rdf objects;")
		# total_docs_scanned += new_obj.length
# 
		# old_obj = resources.get_all_objects_in_archive(old_archive)
		# CollexEngine.report_line("retrieved #{old_obj.length} old objects;\n")
		# total_errors = self.compare_object_arrays(new_obj, old_obj, total_errors)
# 
		# CollexEngine.report_line("Total Docs Scanned: #{total_docs_scanned}. Total Errors: #{total_errors}. Total Docs in index: #{resources.num_docs()}\n")
	# end

	def enumerate_all_recs_in_archive(archive, is_text, page_size)
		done = false
		page = 0
		while !done do
			begin
				if is_text
					objs = get_text_fields_in_archive(archive, page, page_size)
				else
					objs = get_all_objects_in_archive(archive)
					done = true
				end
			rescue Exception => e
				CollexEngine.report_line("ENUMERATE RECS: Continuing after exception: #{e}\n")
				objs = []
			end
			page += 1
			if objs.length < page_size
				done = true
			end
			objs.each {|obj|
				yield obj
			}
		end
	end
	
	# def self.compare_text_one_archive(archive, reindexed_core, old_core, size)
			# CollexEngine.report_line("====== Scanning archive \"#{archive}\"... ====== \n")
			# start_time = Time.now
			# done = false
			# page = 0
			# #size = 10
			# total_objects = 0
			# total_errors = 0
			# docs_with_text = 0
			# new_obj = []
			# old_objs_hash = {}
			# largest_remaining_size = 0
			# old_archive = self.create_old_archive_name(archive)
# 
			# while !done do
				# begin
					# objs = reindexed_core.get_text_fields_in_archive(archive, page, size)
				# rescue Exception => e
					# CollexEngine.report_line("COMPARE TEXT: Continuing after exception: #{e}\n")
					# objs = []
				# end
				# total_objects += objs.length
				# new_obj += objs
				# #CollexEngine.report_line("new_obj.length=#{objs.length}\n")
				# old_objs = old_core.get_text_fields_in_archive(old_archive, page, size)
				# print "."
				# puts "" if total_objects % (150*size) == 0
				# #CollexEngine.report_line("old_obj.length=#{old_objs.length}\n")
				# page += 1
				# if objs.length < size
					# done = true
				# end
				# # first turn the old objects into a hash for quicker searching
				# old_objs.each {|obj|
					# uri = obj['uri']
					# old_objs_hash[uri] = obj
				# }
				# # compare all the items in this set. We might not find all the same objects depending on what order we get them
				# # back from solr, but we'll eliminate the ones we find, then get more.
				# new_obj.each_with_index { |obj, i|
					# uri = obj['uri']
					# old_obj = old_objs_hash[uri]
					# if old_obj
						# total_errors, err_arr, docs_with_text = CompareSolrObject.compare_text(obj, old_obj, total_errors, docs_with_text)
						# err_arr.each { |err| CollexEngine.report_line(err) }
						# new_obj[i] = nil	# we've done this one, so get rid of it
						# old_objs_hash.delete(uri)
					# end
# 					
				# }
				# new_obj = new_obj.compact()
				# largest_remaining_size = new_obj.length if new_obj.length > largest_remaining_size
				# largest_remaining_size = old_objs_hash.length if old_objs_hash.length > largest_remaining_size
			# end
# 
		# # These are all the documents that didn't match anything in the old index.
		# if new_obj.length > 0
			# CollexEngine.report_line(" ============================= TEXT ADDED TO ARCHIVE ===========================\n")
		# end
		# new_obj.each { |obj|
			# CollexEngine.report_line("---------------------------------------------------------------------------------------------------------------\n")
			# CollexEngine.report_line(" --- #{ obj['uri']} ---\n")
			# if obj['text']
				# CollexEngine.report_line("#{obj['text']}\n")
				# total_errors += 1
# #			else
# #				CollexEngine.report_line(" --- No full text for this item\n")
			# end
			# CollexEngine.report_line("---------------------------------------------------------------------------------------------------------------\n")
		# }
		# CollexEngine.report_line("    error: #{total_errors}; docs in archive: #{total_objects}; docs with text: #{docs_with_text}; largest remaining size: #{largest_remaining_size}; duration: #{Time.now-start_time} seconds.\n")
		# return total_objects, total_errors
	# end
# 

	# public
	# def self.compare_reindexed_core_text(params)
		# archive_to_scan = params[:archive]
		# start_after = params[:start_after]
		# use_merged_index = params[:use_merged_index]
		# size = params[:size]
		# CollexEngine.set_report_file(params[:log])
		# resources = CollexEngine.new(['resources'])
		# total_docs_scanned = 0
		# total_errors = 0
# 
		# if archive_to_scan
			# if use_merged_index
				# reindexed = CollexEngine.new(["merged"])
			# else
				# core_name = archive_to_core_name(archive_to_scan)
				# reindexed = CollexEngine.new(["archive_#{core_name}"])
			# end
			# total_docs_scanned, total_errors = compare_text_one_archive(archive_to_scan, reindexed, resources, size)
		# else
			# CollexEngine.report_line("compare_reindexed_core_text needs an archive parameter.\n")
		# end
		# CollexEngine.report_line("Total Docs Scanned: #{total_docs_scanned}. Total Errors: #{total_errors}. Total Docs in index: #{resources.num_docs()}\n")
	# end

	public	# these should actually be some sort of private since they are only called inside this file.
	def self.archive_to_core_name(archive)
		return archive.gsub(":", "_").gsub(" ", "_").gsub(",", "_")
	end

	public
	# This looks at the production uri's and compares them to the reindex uri's and prints out the missing ones.
	def self.get_list_of_skipped_objects(params)
		use_merged_index = params[:use_merged_index]
		archive_to_scan = params[:archive]
		resources = CollexEngine.new(['resources'])
		CollexEngine.set_report_file(params[:log])
		archives = resources.get_all_archives()
		num_not_indexed = 0
		num_new = 0
		archives.each {|archive|
			if (archive_to_scan == nil || archive_to_scan == archive)
				CollexEngine.report_line("====== Scanning archive \"#{archive}\"... ====== ")
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
				CollexEngine.report_line("retrieved #{new_obj.length} new objects...")
				old_obj = resources.get_all_uris_in_archive(archive)
				CollexEngine.report_line("retrieved #{old_obj.length} old objects...\n")
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
					CollexEngine.report_line("    Old: #{uri}\n")
				}
				num_new += new_only.length
				new_only.each { |uri|
					CollexEngine.report_line("    New: #{uri}\n")
				}
			end
		}	# each archive


		CollexEngine.report_line("Total not indexed: #{num_not_indexed}. Total new: #{num_new}. Total Docs in index: #{resources.num_docs()}\n")
	end

	def optimize()
		@solr.optimize() #(:wait_searcher => true, :wait_flush => true)
  end

private
	# def self.print_error(uri, total_errors, first_error, msg)
		# CollexEngine.report_line("---#{uri}---\n") if first_error
		# total_errors += 1
		# first_error = false
		# CollexEngine.report_line("    #{msg}\n")
		# return total_errors, first_error
	# end

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
  	#queries << "federation:#{DEFAULT_FEDERATION}"

    queries << "*:*" if queries.empty?

    [queries.join(" "), filter_queries]
  end

  def facets_to_hash(facet_data)
    # TODO: change how <unspecified> is dealt with, so that it can link back to a -field:[* TO *] query.
    #       Leave nil as-is here, let the UI deal with rendering it as <unspecified>
    facets = {}
    facet_data.each do |facet,values|
      facets[facet] = {}
      CollexEngine.paired_array_each(values) do |key, value|
        # despite requesting mincount => 1, nil (aka "<unspecified>") items can be returned with zero count anyway
        facets[facet][key || "<unspecified>"] = value if value > 0
      end
    end
    facets
  end
end
