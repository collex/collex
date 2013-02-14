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

	# These are created from the same call to the service, so we'll cache them when we first need them.
	@@carousel = nil
	@@resource_tree = nil
	@@archives = nil
  @@languages = nil

	def self.set_cached_data(carousel, resource_tree, archives, languages)
		@@carousel = carousel
		@@resource_tree = resource_tree
		@@archives = archives
    @@languages = languages
	end

	def self.reset_cached_data()
		@@carousel = nil
		@@resource_tree = nil
		@@archives = nil
    @@languages = nil
	end

	def self.log_catalog(verb, str)
		open("#{Rails.root}/log/catalog_activity.log", 'a') { |f|
			f.puts "#{Time.now} #{verb}: #{str}"
		}
	end

	def initialize(testing)
		@use_test_index = testing
	end

	def self.factory_create(testing)
		return Catalog.new(testing)
	end

	def self.factory_create_user()
		return Catalog.new(false)
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
		params.push("max=15")

		results = call_solr("search/autocomplete", :get, params)
		return results['autocomplete']['result']
	end

	def name_facet(constraints)	# called when the "Click here to see the top authors..." is clicked
		params = parse_constraints(constraints)
		results = call_solr("search/names", :get, params)
		results = results['names']
		authors = results.blank? || results['authors'].blank? ? nil : results['authors']['author']
		authors = [] if authors == nil
		authors = [ authors ] if authors.kind_of?(Hash)
		editors = results.blank? || results['editors'].blank? ? nil : results['editors']['editor']
		editors = [] if editors == nil
		editors = [ editors ] if editors.kind_of?(Hash)
		publishers = results.blank? || results['publishers'].blank? ? nil : results['publishers']['publisher']
		publishers = [] if publishers == nil
		publishers = [ publishers ] if publishers.kind_of?(Hash)
		return { 'role_AUT' => authors.collect { |item| [ item['name'], item['occurrences'] ] },
			 'role_EDT' => editors.collect { |item| [ item['name'], item['occurrences'] ] },
			 'role_PBL' => publishers.collect { |item| [ item['name'], item['occurrences'] ] } }
	end

	def normalize_hits(hits)
		if hits == nil
			hits = []
		elsif hits.kind_of?(Hash)
			hits = [ hits ]
		end
		hits.each { |hit|
			hit.each { |key,val|
				if val.kind_of?(Hash) && val['value']
					if val['value'].kind_of?(String)
						hit[key] = [ val['value'] ]
					else
						hit[key] = val['value']
					end
				end
			}
		}
		return hits
	end

	def nil_return()
		return { 'total_hits' => 0, 'hits' => [], 'facets' => { 'genre' => {}, 'archive' => {}, 'freeculture' => {}, 'has_full_text' => {}, 'federation' => {}, 'typewright' => {} } }
	end

	def search(constraints, start, max, sort_by, sort_ascending)
		sort = sort_by == nil ? "" : "sort=#{sort_by.gsub('_sort', '')} #{sort_ascending ? 'asc' : 'desc'}"
		hl = "hl=on"
		start = start ? "start=#{start}" : ""
		max = max ? "max=#{max}" : ""

		params = parse_constraints(constraints)
		params.push(sort) if sort.length > 0
		params.push(hl) if hl.length > 0
		params.push(start) if start.length > 0
		params.push(max) if max.length > 0

		results = call_solr("search", :get, params)
		if !results['html'].blank?
			page = results['html']
			if page.kind_of?(Hash)
				body = page['body']
				ActiveRecord::Base.logger.info("BODY: " + body.to_s)
			else
				ActiveRecord::Base.logger.info("PAGE: " + page.to_s)
			end
			return nil_return()
		end

		results = results['search']
		ret = { 'total_hits' => results['total'], 'hits' => normalize_hits(results['results']['result']), 'facets' => {} }
#		if ret['hits'] == nil
#			ret['hits'] = []
#		elsif ret['hits'].kind_of?(Hash)
#			ret['hits'] = [ ret['hits'] ]
#		end
#		ret['hits'].each { |hit|
#			hit.each { |key,val|
#				if val.kind_of?(Hash) && val['value']
#					if val['value'].kind_of?(String)
#						hit[key] = [ val['value'] ]
#					else
#						hit[key] = val['value']
#					end
#				end
#			}
#		}

		results['facets'].each { |typ,facets|
			h = {}
			if facets['facet'].kind_of?(Array)
				facets['facet'].each { |facet|
					h[facet['name']] = facet['count']
				}
			else
				if facets['facet']
					h[facets['facet']['name']] = facets['facet']['count']
				end
			end
			ret['facets'][typ] = h
		}
		return ret
	end

	def start_reindex()
		call_solr("locals/#{Setup.default_federation()}", :delete)
	end

	def get_carousel()
		if @@carousel == nil
			get_resource_list()
		end
		return @@carousel
  end

  def get_languages()
    if @@languages == nil
      get_language_list()
    end
    return @@languages
  end

	def get_archives()
		if @@archives == nil
			get_resource_list()
		end
		return @@archives
	end

	def get_archive(handle)
		archives = get_archives()
		archives.each { |archive|
			return archive if archive['handle'] == handle
		}
		return nil
	end

	def get_exhibits()
		exhibits = call_solr("exhibits", :get, ["federation=#{Setup.default_federation()}"])
		if exhibits['exhibits'].blank?
			return []
		else
			if !exhibits['exhibits']['uri'].blank?
				return exhibits['exhibits']['uri']
			else
				# the error case is here.
				return exhibits
			end
		end
	end

	def get_resource_tree()
		# This returns an array of the top level nodes and archives
		# Each node recursively contains an array of its children.
		#@@resource_tree = nil
		if @@resource_tree == nil
			get_resource_list()
		end
		return @@resource_tree
  end

  def get_language_list()
    # Right now we're ignoring any languages that aren't ISO 639.2
    response = call_solr("search/languages", :get)
    @@languages = []
    if response['languages'] and response['languages']['language']
      if response['languages']['language'].class == Array
        response['languages']['language'].each { |language|
          iso_lang = nil
          if language['name'] && language['name'].length > 3
            iso_lang = @@languages.find { |l| l.english_name == language['name']}
            if iso_lang.nil?
              iso_lang = IsoLanguage.find_by_english_name(language['name'])
              @@languages.push(iso_lang) if not iso_lang.nil?
            end
          elsif language['name'] && language['name'].length == 3
            iso_lang = @@languages.find { |l| l.alpha3 == language['name']}
            if iso_lang.nil?
              iso_lang = IsoLanguage.find_by_alpha3(language['name'])
              @@languages.push(iso_lang) if not iso_lang.nil?
            end
          elsif language['name']
            iso_lang = @@languages.find { |l| l.alpha2 == language['name']}
            if iso_lang.nil?
              iso_lang = IsoLanguage.find_by_alpha2(language['name'])
              @@languages.push(iso_lang) if not iso_lang.nil?
            end
          end

          if language['occurrences'] and iso_lang
            iso_lang['occurrences'] = iso_lang['occurrences'].to_i + language['occurrences'].to_i
          end
        }
      else
        language = response['languages']['language']
        iso_lang = nil
        if language['name'] && language['name'].length > 3
          iso_lang = @@languages.find { |l| l.english_name == language['name']}
          if iso_lang.nil?
            iso_lang = IsoLanguage.find_by_english_name(language['name'])
            @@languages.push(iso_lang) if not iso_lang.nil?
          end
        elsif language['name'] && language['name'].length == 3
          iso_lang = @@languages.find { |l| l.alpha3 == language['name']}
          if iso_lang.nil?
            iso_lang = IsoLanguage.find_by_alpha3(language['name'])
            @@languages.push(iso_lang) if not iso_lang.nil?
          end
        elsif language['name']
          iso_lang = @@languages.find { |l| l.alpha2 == language['name']}
          if iso_lang.nil?
            iso_lang = IsoLanguage.find_by_alpha2(language['name'])
            @@languages.push(iso_lang) if not iso_lang.nil?
          end
        end

        if language['occurrences'] and iso_lang
          iso_lang['occurrences'] = iso_lang['occurrences'].to_i + language['occurrences'].to_i
        end
      end
    end
    @@languages.sort! { |r,l| r['english_name'] <=> l['english_name']}
  end

	def get_resource_list()
		response = call_solr("archives", :get)
		# we now have a list of archives and nodes. We keep the archives as a list,
		# and we keep a separate copy that is turned into a tree.
		@@carousel = []
		if response['html'].present?
			msg = response['html']['body'].to_s
			Catalog.log_catalog("ERROR", msg)
			return
		end

		nodes = response['resource_tree']['nodes']['node']
		id = 1
		nodes.each { |node|
			node['children'] = []
			node['id'] = id
			id += 1
			if node['carousel']
        if node['carousel']['federations'] and node['carousel']['federations']['federation']
          if node['carousel']['federations']['federation'].kind_of?(Array)
            node['carousel']['federations']['federation'].each { |federation|
              if federation.downcase == Setup.site_name().downcase
                img = node['carousel']['image']
                img = Setup.solr_url() + img if img
                @@carousel.push({ :title => node['name'], :description => node['carousel']['description'], :url => node['site_url'], :image => img })
              end
            }
          else
            if node['carousel']['federations']['federation'].downcase == Setup.site_name().downcase
              img = node['carousel']['image']
              img = Setup.solr_url() + img if img
              @@carousel.push({ :title => node['name'], :description => node['carousel']['description'], :url => node['site_url'], :image => img })
            end
          end
        end
			end
		}
		archives = response['resource_tree']['archives']['archive']
		archives.each { |archive|
			archive['id'] = id
			id += 1
			if archive['carousel']
        if archive['carousel']['federations'] and archive['carousel']['federations']['federation']
          if archive['carousel']['federations']['federation'].kind_of?(Array)
            archive['carousel']['federations']['federation'].each { |federation|
              if federation.downcase == Setup.site_name().downcase
                img = archive['carousel']['image']
                img = Setup.solr_url() + img if img
                @@carousel.push({ :title => archive['name'], :description => archive['carousel']['description'], :url => archive['site_url'], :image => img })
              end
            }
          else
            if archive['carousel']['federations']['federation'].downcase == Setup.site_name().downcase
              img = archive['carousel']['image']
              img = Setup.solr_url() + img if img
              @@carousel.push({ :title => archive['name'], :description => archive['carousel']['description'], :url => archive['site_url'], :image => img })
            end
          end
        end
			end
		}

		@@archives = response['resource_tree']['archives']['archive']

		@@resource_tree = []
		nodes.each { |node|
			if node['parent'] == nil
				@@resource_tree.push(node)
			else
				nodes.each { |parent|
					if parent['name'] == node['parent']
						parent['children'].push(node)
						break
					end
				}
			end
		}
		archives.each { |archive|
			if archive['parent'] == nil
				@@resource_tree.push(archive)
			else
				nodes.each { |parent|
					if parent['name'] == archive['parent']
						parent['children'].push(archive)
						break
					end
				}
			end
		}
		#@@resource_tree.sort! { |a,b| a['name'] <=> b['name'] }
		nodes.each { |node|
			node['children'].sort! { |a,b| a['name'] <=> b['name'] }
		}
	end

	def total_user_content()
		response = call_solr("locals", :get, [ "federation=#{Setup.default_federation()}", "max=0" ])
		return response['search']['total'].to_i
	end

	def search_user_content(options)
		# input parameters:
#		facet_exhibit = options[:facet][:exhibit]	# bool
#		facet_cluster = options[:facet][:cluster]	# bool
#		facet_group = options[:facet][:group]	# bool
#		facet_comment = options[:facet][:comment]	# bool
		facet_federation = options[:facet][:federation]	#bool
		facet_section = options[:facet][:section]	# symbol -- enum: classroom|community|peer-reviewed
		member = options[:member]	# array of group
		admin = options[:admin]	# array of group
		search_terms = options[:terms]	# array of strings, they are ANDed
		sort_by = options[:sort_by]	# symbol -- enum: relevancy|title_sort|last_modified
		page = options[:page]	# int
		page_size = options[:page_size]	#int
		facet_group_id = options[:facet][:group_id]	# int
		object_type = options[:facet][:object_type].blank? ? "All" : options[:facet][:object_type].singularize()
		object_type = "DiscussionThread" if object_type == "Discussion"

		if !member.blank?
			member = member.map { |rec| rec.id }
			member = member.join(',')
		end
		if !admin.blank?
			admin = admin.map { |rec| rec.id }
			admin = admin.join(',')
		end
#		if search_terms != nil
#			# get rid of special symbols
#			search_terms = search_terms.gsub(/\W/, ' ')
#			arr = search_terms.split(' ')
#			arr.each {|term|
#				query += " AND content:#{term}"
#			}
#		end
		query = search_terms
		query = nil if query == nil || query.length == 0

		#TODO: implement visibility
#		group_members = ""
#		member.each {|ar|
#			group_members += " OR visible_to_group_member:#{ar.id}"
#		}
#
#		group_admins = ""
#		admin.each {|ar|
#			group_admins += " OR visible_to_group_admin:#{ar.id}"
#		}
#		query += " AND (visible_to_everyone:true #{group_members} #{group_admins})"
#		if facet_group_id
#			query += " AND group_id:#{facet_group_id}"
#		end

#		arr = []
#		arr.push("object_type:Exhibit") if facet_exhibit
#		arr.push("object_type:Cluster") if facet_cluster
#		arr.push("object_type:Group") if facet_group
#		arr.push("object_type:DiscussionThread") if facet_comment
#		all_query = query
#		if arr.length > 0
#			query += " AND ( #{arr.join(' OR ')})"
#		end

		case sort_by
		when :relevancy then sort = nil
		when :title_sort then sort = "title asc"
		when :last_modified then sort = "#{sort_by.to_s} desc"
		end

		params = []
		params.push("start=#{page*page_size}")
		params.push("max=#{page_size}")
		params.push("sort=#{sort}") if sort
		params.push("q=+#{query.gsub(/\s+/, '+')}") if query
		params.push("section=#{facet_section}")
		params.push("federation=#{facet_federation}")
		params.push("object_type=#{object_type}") if object_type && object_type != 'All'
		params.push("group=#{facet_group_id}") if facet_group_id
		params.push("member=#{member}") if !member.blank?
		params.push("admin=#{admin}") if !admin.blank?
		response = call_solr("locals", :get, params)

		# TODO-hack: if the results is empty, it is returned as a weird hash instead
		if response['search']['total'].to_i == 0
			response['search']['results'] = { 'result' => [] }
		elsif response['search']['results']['result'].kind_of?(Hash)
			response['search']['results']['result'] = [ response['search']['results']['result'] ]
		end
		results = { :total_hits => response['search']['total'].to_i, :total => response['search']['total_documents'].to_i, :hits => response['search']['results']['result'] }
		# add the highlighting to the object
		#TODO: also do highlighting
#		if response['highlighting'] && search_terms != nil
#			highlight = response['highlighting']
#			results[:hits].each  {|hit|
#				this_highlight = highlight[hit['key']]
#				hit['text'] = this_highlight if this_highlight && this_highlight['text']
#			}
#		end
		# the time is a string formatted as: 1995-12-31T23:59:59Z or 1995-12-31T23:59:59.999Z
		if results[:hits].present?
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
    end
    return results
	end

	def format_date(d)
		str = "#{d}"
		str = str.gsub(" UTC", "Z")
		str = str.gsub(" ", "T")

		return str
	end

	def add_local_object(object_type, id, federation, section, title, text, last_modified, visibility_type, group_id)
		return if title == nil || title.length == 0

		doc = ["object_type=#{object_type}", "object_id=#{id}", "federation=#{federation}",
			"section=#{section}", "title=#{title.gsub("’", "'")}", "text=#{text.gsub("’", "'")}", "last_modified=#{format_date(last_modified)}"
		]
		if group_id != nil && group_id.to_i > 0
			doc.push("group_id=#{group_id}")
		end

		if visibility_type == 'everyone'
			doc.push("visible_to_everyone=true")
		else
			doc.push("visible_to_everyone=false")
			if visibility_type == 'member'
				doc.push("visible_to_group_member=#{group_id}")
			else
				doc.push("visible_to_group_admin=#{group_id}")
			end
		end
		call_solr("locals", :post, doc)
	end

	def remove_local_object(object_type, id, federation)
		doc = ["object_type=#{object_type}", "object_id=#{id}", "federation=#{federation}"]
		call_solr("locals", :post, doc)
	end

	def local_commit()
		call_solr("locals/#{Setup.default_federation()}", :put)
	end

	def get_object(uri) #called when "collect" is pressed.
		response = call_solr("search/details", :get, [ "uri=#{uri}" ])
		return normalize_hits(response['search']['results']['result'])[0]
	end

	def add_object(fields, should_commit) # called by Exhibit to index exhibits
		# TODO: Set parameters.
		params = fields
		params["commit"] = "immediate" if should_commit
		params = params.map { |key,val|
			if val.kind_of?(Array)
				"#{key}=#{val.join(';')}"
			else
				"#{key}=#{val}"
			end
		}
		call_solr("exhibits", :post, params)
		Catalog.reset_cached_data()
	end

	def delete_exhibit(id, should_commit)
		params = [ "federation=#{Setup.default_federation()}" ]
		params.push("commit=immediate") if should_commit
		call_solr("exhibits/#{id}", :delete, params)
		Catalog.reset_cached_data()
	end

	def get_federations()
		feds = call_solr("federations", :get)
		ret = {}
		return ret if feds['federations'] == nil || feds['federations']['federation'] == nil
		feds['federations']['federation'].each { |fed|
			ret[fed['name']] = fed
		}
		return ret
	end

	def get_genres()
		genres = call_solr("genres", :get)
		ret = []
		genres['genres']['genre'].each { |gen|
			ret.push(gen['name'])
		}
		return ret
	end

	def get_disciplines()
		disciplines = call_solr("disciplines", :get)
		ret = []
		disciplines['disciplines']['discipline'].each { |disc|
			ret.push(disc['name'])
		}
		return ret
	end

	private
	def query_totals()
		results = call_solr("search/totals", :get)
		if results && results['totals'] && results['totals']['federation']
			objs = results['totals']['federation']
			objs = [ objs ] if objs.kind_of?(Hash)
			objs.each { |obj|
				if obj['name'] == Setup.default_federation()
					@num_docs = obj['total']
					@num_sites = obj['sites']
				end
			}
		end
	end

	def wordify_constraint(prefix, value)
		words = value.split(' ')
		words = words.map { |word| prefix + word }
		joiner = prefix.blank? ? ' ' : ''
		return words.join(joiner)
	end

	def format_federation_constraint(federations)
		value = federations.join(" OR ")
		return "f=+federation:(#{value})"
	end

	def format_constraint(str, constraint, prefix, override = "")
		if str.length == 0
			str = "#{prefix}="
		end
		op = constraint['inverted'] ? '-' : '+'
		should_split = constraint['fieldx'] == 'author' || constraint['fieldx'] == 'publisher' || constraint['fieldx'] == 'editor' || constraint['fieldx'] == 'title'
		should_split = false if constraint['value'] && constraint['value'].include?('"')
		value = should_split ? wordify_constraint(op, constraint['value']) : "#{op}#{constraint['value']}"
		str += override.length > 0 ? (op + override) : value
		return str
	end

	def strip_non_alpha(constraint)
		constraint['value'] = constraint['value'].gsub('-', ' ').gsub(/[\(\):\}\{\^\]\[&@$%=|;,.<>]/u, '').gsub(/\s+/, ' ').strip()
		return constraint
	end

	def parse_constraints(constraints)
		q = ""
    fuz_q = ""
		t = ""
    fuz_t = ""
		aut = ""
		ed = ""
		pub = ""
		y = ""
		a = ""
		g = ""
		f = ""
		o = ""
    r_art = ""
    r_own = ""
    lang = ""
    discipline = ""
    doc_type = ""
    role = ""
		federations = []

    params = []

		constraints.each { |constraint|
			if constraint['type'] == 'FederationConstraint'
				federations.push(constraint['value'])
			elsif constraint['type'] == 'ExpressionConstraint'
				q = format_constraint(q, strip_non_alpha(constraint), 'q')
			elsif constraint['type'] == 'FreeCultureConstraint'
				o = format_constraint(o, constraint, 'o', 'freeculture')
			elsif constraint['type'] == 'FullTextConstraint'
				o = format_constraint(o, constraint, 'o', 'fulltext')
			elsif constraint['type'] == 'TypeWrightConstraint'
				o = format_constraint(o, constraint, 'o', 'typewright')
			elsif constraint['type'] == 'FacetConstraint'
				if constraint['fieldx'] == 'genre'
					g = format_constraint(g, constraint, 'g')
				elsif constraint['fieldx'] == 'archive'
					a = format_constraint(a, constraint, 'a')
				elsif constraint['fieldx'] == 'title'
					t = format_constraint(t, strip_non_alpha(constraint), 't')
				elsif constraint['fieldx'] == 'author'
					aut = format_constraint(aut, strip_non_alpha(constraint), 'aut')
				elsif constraint['fieldx'] == 'editor'
					ed = format_constraint(ed, strip_non_alpha(constraint), 'ed')
				elsif constraint['fieldx'] == 'publisher'
					pub = format_constraint(pub, strip_non_alpha(constraint), 'pub')
        elsif constraint['fieldx'] == 'r_art'
          r_art = format_constraint(r_art, strip_non_alpha(constraint), 'r_art')
        elsif constraint['fieldx'] == 'r_own'
          r_own = format_constraint(r_own, strip_non_alpha(constraint), 'r_own')
				elsif constraint['fieldx'] == 'fuz_q'
          fuz_q = format_constraint(fuz_q, constraint, 'fuz_q')   # TODO: Strip non-digits
        elsif constraint['fieldx'] == 'fuz_t'
          fuz_t = format_constraint(fuz_t, constraint, 'fuz_t')   # TODO: Strip non-digits
        elsif constraint['fieldx'] == 'year'
          y = format_constraint(y, constraint, 'y')
        elsif constraint['fieldx'] == 'language'
          lang = format_constraint(lang, constraint, 'lang')
        elsif constraint['fieldx'] == 'doc_type'
          doc_type = format_constraint(doc_type, constraint, 'doc_type')
        elsif constraint['fieldx'] == 'discipline'
          discipline = format_constraint(discipline, constraint, 'discipline')
        elsif constraint['fieldx'].match(/role_/)
          role = format_constraint(role, constraint, constraint['fieldx'])    # fieldx is also the url param for role_*
          params.push(role) if role.length > 0
          role = ''
				else
					raise Catalog::Error.new("Unhandled constraint")
				end
			else
				raise Catalog::Error.new("Unhandled constraint")
			end
		}

		f = format_federation_constraint(federations) if federations.present?

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
    params.push(r_art) if r_art.length > 0
    params.push(r_own) if r_own.length > 0
    params.push(fuz_q) if fuz_q.length > 0
    params.push(fuz_t) if fuz_q.length > 0
    params.push(lang) if lang.length > 0
    params.push(doc_type) if doc_type.length > 0
    params.push(discipline) if discipline.length > 0

		return params
	end

	def esc_arg(item)
		# This takes a string in the form key=value and just escapes the value portion
		arr = item.split('=', 2)
		if arr.length == 2
			return "#{arr[0]}=#{CGI.escape(arr[1])}"
		else
			return CGI.escape(item)
		end
	end

	require 'net/http'
	def call_solr(url, verb, params = [])
		params.push("test_index=true") if @use_test_index
		args = params.length > 0 ? "#{params.collect { |item| esc_arg(item) }.join('&')}" : ""
		request = "/#{url}.xml"
		url = URI.parse(Setup.solr_url())
		Catalog.log_catalog(verb.to_s().upcase(), "#{url}#{request} ARGS: #{args}")
		begin
			res = Net::HTTP.start(url.host, url.port) do |http|
				if verb == :get
					args = '?' + args if args.length > 0
					http.get("#{request}#{args}")
				elsif verb == :post
					http.post(request, args)
				elsif verb == :put
					#args += args.length > 0 ? '&' : '?'
					#args += "_method=PUT"
					http.put(request, args)
				elsif verb == :delete
					#args += args.length > 0 ? '&' : '?'
					#args += "_method=DELETE"
					del = Net::HTTP::Delete.new(request)
					http.request(del, args)
					#http.delete(request, args)
				end
			end
		rescue Exception => e
			msg = e.to_s
			if msg == "getaddrinfo: nodename nor servname provided, or not known"
				msg = "Cannot connect to the Catalog using the address \"#{url}\"."
			else
				msg = "Search error: #{url} returns: #{msg}"
			end
			Catalog.log_catalog("ERROR", msg)
			raise Catalog::Error.new(msg)
		end

		begin
	 		results = Hash.from_xml(res.body)
		rescue Exception => e
			msg = res.body
			Catalog.log_catalog("ERROR", msg)
			raise Catalog::Error.new(msg)
		end

		#ActiveRecord::Base.logger.info("RESULTS: #{results.to_s}")
		errs = results['error']
		if errs != nil
			msg = "Search error: #{url} returns: #{errs['message']}"
			Catalog.log_catalog("ERROR", msg)
			raise Catalog::Error.new(msg)
		end
		return results
	end
end
