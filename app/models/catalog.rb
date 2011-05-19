# encoding: UTF-8
##########################################################################
# Copyright 2011 Applied Research in Patacriticism and the University of Virginia
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

# This is the interface for CollexCatalog
class Catalog
	class Error < RuntimeError
	end

	def num_docs	# called for each entry point to get the number for the footer.
		query_totals() if @num_docs == nil
		return @num_docs
	end

	def num_sites	# called for each entry point to get the number for the footer.
		query_totals() if @num_sites == nil
		return @num_sites
	end

	def auto_complete(facet, constraints, prefix)	# called for autocomplete
		params = parse_constraints(constraints)
		params.push("frag=#{prefix}")
		params.push("field=#{facet}") if facet != 'content'

		results = call_solr("search/autocomplete", params)
		return results['hash']
	end

	def name_facet(constraints)	# called when the "Click here to see the top authors..." is clicked
		params = parse_constraints(constraints)
		results = call_solr("search/names", params)
		return results['hash']
	end

	def search(constraints, start, max, sort_by, sort_ascending)
		sort = sort_by == nil ? "" : "sort=#{sort_by.gsub('_sort', '')}+#{sort_ascending ? 'asc' : 'desc'}"
		hl = "hl=on"
		start = "start=#{start}"
		max = "max=#{max}"

		params = parse_constraints(constraints)
		params.push(sort) if sort.length > 0
		params.push(hl) if hl.length > 0
		params.push(start) if start.length > 0
		params.push(max) if max.length > 0

		results = call_solr("search", params)
		ret = { 'total_hits' => results['hash']['total'], 'hits' => results['hash']['hits'], 'facets' => {} }
		results['hash']['facets'].each { |typ,facets|
			h = {}
			facets.each { |facet|
				h[facet['name']] = facet['count']
			}
			ret['facets'][typ] = h
		}
		return ret
	end

	def get_resource_list()
		raise Catalog::Error.new("Unhandled function: get_resource_list")
	end

	def search_user_content(options)
		raise Catalog::Error.new("Unhandled function: search_user_content")
	end

	def get_object(uri, all_fields = false) #called when "collect" is pressed.
		raise Catalog::Error.new("Unhandled function: get_object")
	end

	def add_object(fields, relevancy = nil, is_retry = false) # called by Exhibit to index exhibits
		raise Catalog::Error.new("Unhandled function: add_object")
	end

	private
	def query_totals()
		results = call_solr("search/totals")
		objs = results['objects']
		objs.each { |obj|
			if obj['federation'] == DEFAULT_FEDERATION
				@num_docs = obj['total']
				@num_sites = obj['sites']
			end
		}
	end

	def format_constraint(str, constraint, prefix, override = "")
		str = "#{prefix}=" if str.length == 0
		str += constraint['inverted'] ? '-' : '%2b'
		str += override.length > 0 ? override : constraint['value']
		return str
	end

	def parse_constraints(constraints)
		q = ""
		t = ""
		aut = ""
		ed = ""
		pub = ""
		y = ""
		a = ""
		g = ""
		f = ""
		o = ""

		constraints.each { |constraint|
			if constraint['type'] == 'FederationConstraint'
				f = format_constraint(f, constraint, 'f')
			elsif constraint['type'] == 'ExpressionConstraint'
				q = format_constraint(q, constraint, 'q')
			elsif constraint['type'] == 'FreeCultureConstraint'
				o = format_constraint(o, constraint, 'o', 'freeculture')
			elsif constraint['type'] == 'FullTextConstraint'
				o = format_constraint(o, constraint, 'o', 'fulltext')
			elsif constraint['type'] == 'FacetConstraint'
				if constraint['fieldx'] == 'genre'
					g = format_constraint(g, constraint, 'g')
				elsif constraint['fieldx'] == 'archive'
					a = format_constraint(a, constraint, 'a')
				elsif constraint['fieldx'] == 'title'
					t = format_constraint(t, constraint, 't')
				elsif constraint['fieldx'] == 'author'
					aut = format_constraint(aut, constraint, 'aut')
				elsif constraint['fieldx'] == 'editor'
					ed = format_constraint(ed, constraint, 'ed')
				elsif constraint['fieldx'] == 'publisher'
					pub = format_constraint(pub, constraint, 'pub')
				elsif constraint['fieldx'] == 'year'
					y = format_constraint(y, constraint, 'y')
				else
					raise Catalog::Error.new("Unhandled constraint")
				end
			else
				raise Catalog::Error.new("Unhandled constraint")
			end
		}
		params = []
		params.push(q) if q.length > 0
		params.push(t) if t.length > 0
		params.push(aut) if aut.length > 0
		params.push(ed) if ed.length > 0
		params.push(pub) if pub.length > 0
		params.push(y) if y.length > 0
		params.push(a) if a.length > 0
		params.push(g) if g.length > 0
		params.push(f) if f.length > 0
		params.push(o) if o.length > 0

		return params
	end

	def call_solr(url, params = [])
		args = params.length > 0 ? "?#{params.join('&')}" : ""
		request = "#{SOLR_URL}/#{url}.xml#{args}"
		puts "SOLR REQUEST: #{request}"
		raw = `curl \"#{request}\"`
		results = Hash.from_xml(raw)
		objs = results['objects']
		if objs != nil && objs.length == 1 && objs[0]['error'] != nil
			raise Catalog::Error.new("Search error: #{url} returns: #{objs[0]['error']}")
		end
		return results
	end
end
