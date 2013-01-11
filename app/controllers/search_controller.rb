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

class SearchController < ApplicationController
   layout 'nines'
   #before_filter :authorize, :only => [:collect, :save_search, :remove_saved_search]
   before_filter :init_view_options
   
   def initialize

   end
   
   private
   def init_view_options
     @site_section = :search
	 @solr = Catalog.factory_create(session[:use_test_index] == "true")
	 session[:constraints] ||= new_constraints_obj()
     return true
   end
   public


   # Add a TypeWright constraint. This will add the constraint contained
   # in params[:search_phrase] and the typewright constraint. Called from
   # the TypeWright tab. Note that all prior constrains are wiped out to
   # ensure a fresh set of results
   #
   def add_tw_constraint
    if params[:search_phrase]
      clear_constraints()
      session[:constraints] << TypeWrightConstraint.new(:inverted => false )
      parse_keyword_phrase( params[:search_phrase], false)
    end
    redirect_to :action => 'browse'
   end

   def add_constraint
     session[:name_of_search] = nil
      # There are two types of input we can receive here, depending on whether the search form was expanded.
      # There might be a different input box for each type of search, or there might be a single input box with a select field determining the type.

      if params[:search_phrase]
        # basic search
        # We were called from the home page, so make sure there aren't any constraints laying around
        clear_constraints()
        parse_keyword_phrase(params[:search_phrase], false) #if params[:search_type] == "Search Term"

        # in case we put a fuzzy search slider on the home page
        add_keyword_fuz_constraint(params[:search_keyword_fuz], false) if params[:search_keyword_fuz] != ""

      elsif params[:search] && params[:search][:phrase] == nil
        # expanded input boxes
        parse_keyword_phrase(params[:search][:keyword], false) if params[:search] && params[:search][:keyword] != ""
        add_title_constraint(params[:search_title], false) if params[:search_title] != ""
        add_author_constraint(params[:search_author], false) if params[:search_author] != ""
        add_editor_constraint(params[:search_editor], false) if params[:search_editor] != ""
        add_owner_constraint(params[:search_owner], false) if params[:search_owner] != ""
        add_artist_constraint(params[:search_artist], false) if params[:search_artist] != ""
        add_publisher_constraint(params[:search_publisher], false) if params[:search_publisher] != ""
        add_date_constraint(params[:search_year], false) if params[:search_year] != ""
        add_language_constraint(params[:search_language], false) if params[:search_language] != ""

        # add the role_* constraints
        params.each { |key, value|
          if key.match(/search_role_/) and value != ""
            role = key.sub(/search_/, '')
            add_role_constraint(role, value, false)
          end
        }

        add_keyword_fuz_constraint(params[:search_keyword_fuz], false) if params[:search_keyword_fuz] != ""
        add_title_fuz_constraint(params[:search_title_fuz], false) if params[:search_title_fuz] != ""


      elsif params[:search]
        # single input box
        invert = (params[:search_not] == "NOT")
        if not params[:search][:phrase].strip.empty?
          case params[:search_type]
            when "Search Term"
              parse_keyword_phrase(params[:search][:phrase], invert)
            when "Title"
              add_title_constraint(params[:search][:phrase], invert)
            when "Author"
              add_author_constraint(params[:search][:phrase], invert)
            when "Editor"
              add_editor_constraint(params[:search][:phrase], invert)
            when "Owner"
              add_owner_constraint(params[:search][:phrase], invert)
            when "Artist"
              add_artist_constraint(params[:search][:phrase], invert)
            when "Publisher"
              add_publisher_constraint(params[:search][:phrase], invert)
            when "Year (YYYY)"
              add_date_constraint(params[:search][:phrase], invert)
            when "Language"
              add_language_constraint(params[:search_language], invert)
            else
              role = Search.role_field_names.find{ |key, value| value[:display] == params[:search_type]}
              if role
                add_role_constraint(role[0], params[:search][:phrase], invert)
              end
          end
          #parse_keyword_phrase(params[:search][:phrase], invert) if params[:search_type] == "Search Term"
          #add_title_constraint(params[:search][:phrase], invert) if params[:search_type] == "Title"
          #add_author_constraint(params[:search][:phrase], invert) if params[:search_type] == "Author"
          #add_editor_constraint(params[:search][:phrase], invert) if params[:search_type] == "Editor"
          #add_owner_constraint(params[:search][:phrase], invert) if params[:search_type] == "Owner"
          #add_artist_constraint(params[:search][:phrase], invert) if params[:search_type] == "Artist"
          #add_publisher_constraint(params[:search][:phrase], invert) if params[:search_type] == "Publisher"
          #add_date_constraint(params[:search][:phrase], invert) if params[:search_type] == "Year (YYYY)"
          #add_language_constraint(params[:search_language], invert) if params[:search_type] == "Language"
        end

        # see if the fuz_constraints are already present
        keyword_fuz_constraint = session[:constraints].find{ |i| i[:fieldx] == 'fuz_q'};
        title_fuz_constraint = session[:constraints].find{ |i| i[:fieldx] == 'fuz_t'};

        # set or reset the fuz_constraints if needed
        if keyword_fuz_constraint.nil?
          add_keyword_fuz_constraint(params[:search_keyword_fuz], false) if params[:search_keyword_fuz] != ""
        else
          modify_keyword_fuz_constraint(params[:search_keyword_fuz], false, keyword_fuz_constraint) if params[:search_keyword_fuz] != ""
        end
        if title_fuz_constraint.nil?
          add_title_fuz_constraint(params[:search_title_fuz], false) if params[:search_title_fuz] != ""
        else
          modify_title_fuz_constraint(params[:search_title_fuz], false, title_fuz_constraint) if params[:search_title_fuz] != ""
        end

      end

		 session[:name_facet_msg] = "You just added \"#{params[:search][:phrase]}\" as a constraint." if params[:from_name_facet] == "true"
     redirect_to :action => 'browse'
   end
   
	def add_federation_constraint
		session[:name_of_search] = nil
		constraints = params[:federation]
		is_checked = params[:checked]
		session[:constraints] = [] if session[:constraints] == nil
		# first get rid of any current federation constraint so there will never be more than one
		#idx = -1
		#session[:constraints].each_with_index { |constraint, i|
		#	idx = i if constraint.is_a?(FederationConstraint)
		#}
		#if idx >= 0
		#	session[:constraints].delete_at(idx)
		#end
		idx = -1
		has_fed = false
		session[:constraints].each_with_index { |constraint, i|
			idx = i if constraint.is_a?(FederationConstraint) && constraint.value == constraints
			has_fed = true if constraint.is_a?(FederationConstraint)
		}
		if is_checked == 'true'
			if constraints == 'search_federation'
				session[:constraints].delete_if { |constraint| constraint.is_a?(FederationConstraint) }
			elsif idx < 0	# If it is already set, then ignore it.
				session[:constraints] << FederationConstraint.new(:fieldx => 'federation', :value => constraints, :inverted => false)
			end
		else
			if constraints == 'search_federation'
				session[:constraints].delete_if { |constraint| constraint.is_a?(FederationConstraint) }
				session[:constraints] << FederationConstraint.new(:fieldx => 'federation', :value => Setup.default_federation(), :inverted => false)
			elsif idx >= 0	# If it already doesn't exist, then ignore it,
				session[:constraints].delete_at(idx)
			elsif !has_fed # unless there are no federation constraints
				if !session['federations'].blank?
					session['federations'].each { |key,val|
						if key != constraints
							session[:constraints] << FederationConstraint.new(:fieldx => 'federation', :value => key, :inverted => false)
						end
					}
				end
			end
		end

		# Now, normalize the constraints: if all of them have been specified, delete them all.
		count = 0
		session[:constraints].each_with_index { |constraint, i|
			idx = i if constraint.is_a?(FederationConstraint) && constraint.value == constraints
			count += 1 if constraint.is_a?(FederationConstraint)
		}
		if !session['federations'].blank? && count == session['federations'].length
			session[:constraints].delete_if { |constraint| constraint.is_a?(FederationConstraint) }
		end

		#if constraints != nil	# if no federation was passed in, that means we want to change it to search all federations, so we have nothing else to do.
		#	session[:constraints] << FederationConstraint.new(:fieldx => 'federation', :value => constraints, :inverted => false)
		#end
		red_hash = { :action => 'browse' }
		red_hash[:phrs] = params[:phrs] if params[:phrs]
		red_hash[:kphrs] = params[:kphrs] if params[:kphrs]
		red_hash[:tphrs] = params[:tphrs] if params[:tphrs]
		red_hash[:aphrs] = params[:aphrs] if params[:aphrs]
		red_hash[:ephrs] = params[:ephrs] if params[:ephrs]
		red_hash[:pphrs] = params[:pphrs] if params[:pphrs]
		red_hash[:yphrs] = params[:yphrs] if params[:yphrs]
		redirect_to red_hash
	end

   private
   def parse_keyword_phrase(phrase_str, invert)
     # This breaks the keyword phrase that the user entered into separate searches and adds each constraint separately.

     # first, find quoted sections and replace spaces within them
     # with an '_' so they wont get split by regex
     start_pos = 0
     while true
       p1 = phrase_str.index("\"", start_pos)
       if p1.nil?
         break
       else
         p2 = phrase_str.index("\"", p1+1)
         if p2.nil?
           break
         else
           str = phrase_str[p1..p2]
           str.gsub!(/[\s\-]+/, "_")
           phrase_str = phrase_str[0...p1] + str + phrase_str[p2+1..-1] 
           start_pos = p2+1
           if start_pos >= phrase_str.length
             break
           end
         end
       end
     end
     
       # strip punctuation and other troublesome chars
       # NOTE: for some reason, the escaped brackets only work in ruby regex if
       # they are in the middle of the expression.
      phrase_str.gsub!(/[.\^&=@#\$%\*<>\/\?\|,\[\]!}{+-]/, " ")

     # now, split the string on spaces
     words_arr = phrase_str.split(/[\s\-]+/)
  
     # find AND and get rid of it
     words_arr.delete_if { |word| word.upcase == "AND" }
     
     # NOT/OR cleanup pass through words:
     inverted = {}
     invert_next = false
     words_arr.each_with_index do |word, index|
       
       if word.upcase == "NOT"
         # set a flag so the next word found will be inverted
         invert_next = true  
         words_arr[index] = ""
       #elsif word.upcase == "OR"
       #  # when OR is found at non-terminal position stitch words
       #  if index > 0 && index < words_arr.length - 1
       #    # find the invert state of the current start of the OR
       #    prior_invert = inverted[ words_arr[index-1] ]
       #
       #    # stitch and clear words
       #    words_arr[index] = words_arr[index-1] + " OR " + words_arr[index+1]
       #    words_arr[index-1] = ""
       #    words_arr[index+1] = ""
       #
       #    # carry prior invert state on to the stitched result
       #    inverted[ words_arr[index] ] = prior_invert
       #  else
       #    words_arr[index] = ""
       #  end
       else
         # a preceding OR may have blanked this word out. skip it if so
         if word != ""
           inverted[word] = !invert if invert_next == true
           inverted[word] = invert if invert_next == false
           invert_next = false  
         end
       end
     end

     # Finally, create each constraint for non-empty strings
     words_arr.each do |word|
       if word != ""
		   inv = inverted[word]
         word.gsub!("_", " ")
         add_keyword_constraint(word, inv )
       end
     end

   end
   
   def add_keyword_constraint(phrase_str, invert)
       expression = phrase_str
       if expression and expression.strip.size > 0 && session[:constraints]
         session[:constraints] << ExpressionConstraint.new(:value => expression, :inverted => invert)
       end
   end

   def add_keyword_fuz_constraint(phrase_str, invert)
     expression = phrase_str
     if expression and expression.strip.size > 0 and expression != '1' && session[:constraints]
       session[:constraints] << FacetConstraint.new(:fieldx => 'fuz_q', :value => phrase_str, :inverted => invert)
     end
   end

   def modify_keyword_fuz_constraint(phrase_str, invert, constraint)
     expression = phrase_str
     if expression and expression.strip.size > 0 and expression != '1' && constraint
       constraint[:value] = phrase_str
       constraint[:inverted] = invert
     elsif session[:constraints]
       session[:constraints].delete(constraint)
     end
   end
 
   def add_title_constraint(phrase_str, invert)
       expression = phrase_str
       if expression and expression.strip.size > 0 && session[:constraints]
         session[:constraints] << FacetConstraint.new(:fieldx => 'title', :value => phrase_str, :inverted => invert)
       end
   end

   def modify_title_fuz_constraint(phrase_str, invert, constraint)
     expression = phrase_str
     if expression and expression.strip.size > 0 and expression != '1' && constraint
       constraint[:value] = phrase_str
       constraint[:inverted] = invert
     elsif session[:constraints]
       session[:constraints].delete(constraint)
     end
   end

   def add_title_fuz_constraint(phrase_str, invert)
     expression = phrase_str
     if expression and expression.strip.size > 0 and expression != '1' && session[:constraints]
       session[:constraints] << FacetConstraint.new(:fieldx => 'fuz_t', :value => phrase_str, :inverted => invert)
     end
   end
 
  def add_date_constraint(phrase_str, invert)
     if (phrase_str and not phrase_str.strip.empty?) && session[:constraints]
       session[:constraints] << FacetConstraint.new(:fieldx => 'year', :value => phrase_str, :inverted => invert)
     end
  end
  
  def add_author_constraint(phrase_str, invert)
    if phrase_str and phrase_str.strip.size > 0 && session[:constraints]
       session[:constraints] << FacetConstraint.new(:fieldx => 'author', :value => phrase_str, :inverted => invert)
    end
  end

  def add_artist_constraint(phrase_str, invert)
    if phrase_str and phrase_str.strip.size > 0 && session[:constraints]
      session[:constraints] << FacetConstraint.new(:fieldx => 'r_art', :value => phrase_str, :inverted => invert)
    end
  end

  def add_owner_constraint(phrase_str, invert)
    if phrase_str and phrase_str.strip.size > 0 && session[:constraints]
      session[:constraints] << FacetConstraint.new(:fieldx => 'r_own', :value => phrase_str, :inverted => invert)
    end
  end

  def add_editor_constraint(phrase_str, invert)
    if phrase_str and phrase_str.strip.size > 0 && session[:constraints]
       session[:constraints] << FacetConstraint.new(:fieldx => 'editor', :value => phrase_str, :inverted => invert)
    end
  end

   def add_role_constraint(role, phrase_str, invert)
     if phrase_str and phrase_str.strip.size > 0 && session[:constraints]
       session[:constraints] << FacetConstraint.new(:fieldx => role, :value => phrase_str, :inverted => invert)
     end
   end

  def add_publisher_constraint(phrase_str, invert)
    if phrase_str and phrase_str.strip.size > 0 && session[:constraints]
       session[:constraints] << FacetConstraint.new(:fieldx => 'publisher', :value => phrase_str, :inverted => invert)
    end
  end

   def add_language_constraint(phrase_str, invert)
     if phrase_str and phrase_str.strip.size > 0 && session[:constraints]
       iso_lang = IsoLanguage.find_by_alpha3(phrase_str)
       iso_lang = IsoLanguage.find_by_english_name(phrase_str) if iso_lang.nil?
       iso_lang = IsoLanguage.find_by_alpha2(phrase_str) if iso_lang.nil?
       iso_lang = IsoLanguage.all().find{ |lang| lang.alpha3 == phrase_str.downcase } if iso_lang.nil? and phrase_str.length == 3
       iso_lang = IsoLanguage.all().find{ |lang| lang.alpha2 == phrase_str.downcase } if iso_lang.nil? and phrase_str.length == 2
       iso_lang = IsoLanguage.all().find{ |lang| lang.english_name.downcase.match(Regexp.new(phrase_str.downcase + ';')) } if iso_lang.nil?
       iso_lang = IsoLanguage.all().find{ |lang| lang.english_name.downcase.match(Regexp.new(phrase_str.downcase + '\s*$')) } if iso_lang.nil?
       iso_lang = IsoLanguage.all().find{ |lang| lang.english_name.downcase.match(Regexp.new(phrase_str.downcase)) } if iso_lang.nil?
       if not iso_lang.nil?
         if !iso_lang.english_name.nil?
          phrase_str = iso_lang.english_name.split(/;/).join(' || ')
         end
         if !iso_lang.alpha3.nil?
           phrase_str += " || " if !phrase_str.nil? and phrase_str.strip.length > 0
           phrase_str += iso_lang.alpha3
         end
         if !iso_lang.alpha2.nil?
           phrase_str += " || " if !phrase_str.nil? and phrase_str.strip.length > 0
           phrase_str += iso_lang.alpha2
         end

       end
       session[:constraints] << FacetConstraint.new(:fieldx => 'language', :value => phrase_str, :inverted => invert)
     end
   end

  def rescue_search_error(e)
     error_message = e.message
     if (match = error_message.match( /Query_parsing_error_/ ))
       error_message = match.post_match
     else
       error_message = error_message.gsub(/^\d\d\d \"(.*)\"/,'\1')
	 end
	 logger.error("SEARCH ERROR: #{error_message}")
     if session[:constraints].length == 1 && session[:constraints][0]['type'] == "ExpressionConstraint"
       flash[:error] = render_to_string(:inline => "The search string \"#{session[:constraints][0]['value']}\" contains invalid characters. Try another search.")
     else
       flash[:error] = render_to_string(:inline => "You have entered a search string with invalid characters.  You should <%=link_to 'clear all your constraints', { :action => 'new_search' }, { :class => 'nav_link' } %> or remove the offending search string below.")
     end
     return {"facets" => {"archive" => {}, "freeculture" => {}, "genre" => {}}, "total_hits" => 0, "hits" => [], "total_documents" => 0}
  end

   def get_resource_tree
		return session[:resource_tree].blank? ? @solr.get_resource_tree() : session[:resource_tree]
   end

    public
  
   # generate search results based on constraints
	def browse
		if params[:script]
			session[:script] = params[:script]
			session[:uri] = params[:uri]
			session[:row_num] = params[:row_num]
			session[:row_id] = params[:row_id]
			params[:script] = nil
			params[:uri] = nil
			params[:row_num] = nil
			params[:row_id] = nil
			redirect_to params
		else
			if session[:script]
				@script = session[:script]
				@uri = session[:uri]
				@row_num = session[:row_num]
				@row_id = session[:row_id]

				session[:script] = nil
				session[:uri] = nil
				session[:row_num] = nil
				session[:row_id] = nil
			end
			@phrs = params[:phrs]
			@kphrs = params[:kphrs]
			@tphrs = params[:tphrs]
			@aphrs = params[:aphrs]
			@ephrs = params[:ephrs]
			@pphrs = params[:pphrs]
			@yphrs = params[:yphrs]
			@name_facet_msg = session[:name_facet_msg]
			session[:name_facet_msg] = nil

			session[:constraints] ||= new_constraints_obj()
			session[:search_sort_by] ||= 'Relevancy'
			items_per_page = 30
			#session[:selected_resource_facets] ||= FacetCategory.find( :all, :conditions => "type = 'FacetValue'").map { |facet| facet.value }

			@page = params[:page] ? params[:page].to_i : 1

			begin
				@results = search_solr(session[:constraints], @page, items_per_page, session[:search_sort_by], session[:search_sort_by_direction])
				# Add the highlighting to the hit object so that a result is completely contained inside the hit object
				@results['hits'].each { |hit|
					if @results["highlighting"] && hit['uri'] && @results["highlighting"][hit["uri"]]
						hit['text'] = @results["highlighting"][hit["uri"]]
					end
				}
#			rescue  Net::HTTPServerException => e
#				@results = rescue_search_error(e)
			rescue Catalog::Error => e
				@results = rescue_search_error(e)
				@message = e.message
			end

			@num_pages = @results["total_hits"].to_i.quo(items_per_page).ceil
			@total_documents = session[:num_docs] #@results["total_documents"]
			@sites_forest = get_resource_tree()
			# We are sorting by reverse order so that "Peer-Reviewed" comes out on top. This will probably need to get more sophisticated.
			@sites_forest = @sites_forest.sort { |a,b| b['name'] <=> a['name'] }
			@genre_data = marshall_genre_data(@results["facets"]["genre"])
      @format_data = marshall_format_data(@results["facets"]["doc_type"])
      @discipline_data = marshall_discipline_data(@results["facets"]["discipline"])

      if @results['facets']['role']
        @searchable_roles = @results['facets']['role'].keys.map { |field|
          # map role field names to display names
          # example ['role_AUT', 'Author']
          [Search.role_field_names[field][:search_field], Search.role_field_names[field][:display]]
        }
      else
        @searchable_roles = [];
      end

			@citation_count = @results['facets']['genre']['Citation'] || 0
			@freeculture_count = 0
			@freeculture_count = @results['facets']['freeculture']['true'] if @results && @results['facets'] && @results['facets']['freeculture'] && @results['facets']['freeculture']['true']
#			@freeculture_count = @results['facets']['freeculture']['<unspecified>'] || 0
			@fulltext_count = 0
			@fulltext_count = @results['facets']['has_full_text']['true'] if @results && @results['facets'] && @results['facets']['has_full_text'] && @results['facets']['has_full_text']['true']
			@typewright_count = 0
			@typewright_count = @results['facets']['typewright']['true'] if @results && @results['facets'] && @results['facets']['typewright'] && @results['facets']['typewright']['true']
			@all_federations = 'Search all federations'
			@other_federations = []
			session[:federations].each { |key,val| @other_federations.push(key) if key != Setup.default_federation() } if session[:federations]
			@listed_constraints = marshall_listed_constraints()

		      render :layout => 'nines'	#TODO-PER: Why is the layout not working unless it is defined explicitly here?
			#render :action => 'results'
		end
	end
   
	 #adjust the sort order
  def sort_by
    session[:name_of_search] = nil
		if params['search'] && params['search']['result_sort']
      sort_param = params['search']['result_sort']
			session[:search_sort_by] = sort_param
		end
		if params['search'] && params['search']['result_sort_direction']
      sort_param = params['search']['result_sort_direction']
			session[:search_sort_by_direction] = sort_param
		end
      redirect_to :action => 'browse', :phrs => params[:phrs]
	end
   
   # constrain search to only return free culture objects
   def constrain_freeculture
     session[:name_of_search] = nil
     if params[:remove] == 'true'
       session[:constraints].each {|constraint|
         if constraint[:type] == 'FreeCultureConstraint'
           session[:constraints].delete(constraint)
           break
         end
       }
     else
       session[:constraints] << FreeCultureConstraint.new(:inverted => false )
     end
   
     redirect_to :action => 'browse', :phrs => params[:phrs]
   end
   
   # constrain search to only return free culture objects
   def constrain_fulltext
     session[:name_of_search] = nil
     if params[:remove] == 'true'
       session[:constraints].each {|constraint|
         if constraint[:type] == 'FullTextConstraint'
           session[:constraints].delete(constraint)
           break
         end
       }
     else
       session[:constraints] << FullTextConstraint.new(:inverted => false )
     end

     redirect_to :action => 'browse', :phrs => params[:phrs]
   end

   # constrain search to only return typewright objects
   def constrain_typewright
     session[:name_of_search] = nil
     if params[:remove] == 'true'
       session[:constraints].each {|constraint|
         if constraint[:type] == 'TypeWrightConstraint'
           session[:constraints].delete(constraint)
           break
         end
       }
     else
       session[:constraints] << TypeWrightConstraint.new(:inverted => false )
     end

     redirect_to :action => 'browse', :phrs => params[:phrs]
   end

   # constrains the search by the specified resources
   def constrain_resource
     session[:name_of_search] = nil
     resource = params[:resource]
     if params[:remove] == 'true'
       session[:constraints].each {|constraint|
         if constraint[:fieldx] == 'archive' && constraint[:type] == 'FacetConstraint' && constraint[:value] == resource
           session[:constraints].delete(constraint)
           break
         end
       }
     else
       # Delete any previous resource constraint
       session[:constraints].each {|constraint|
         if constraint[:fieldx] == 'archive' && constraint[:type] == 'FacetConstraint'
           session[:constraints].delete(constraint)
           break
         end
       }
       session[:constraints] << FacetConstraint.new( :fieldx => 'archive', :value => resource, :inverted => false )
     end
     
     redirect_to :action => 'browse', :phrs => params[:phrs]
   end
   
   def add_facet
     session[:name_of_search] = nil
     if params[:fieldx] and params[:value]
       session[:constraints] << FacetConstraint.new(:fieldx => params[:fieldx], :value => params[:value], :inverted => params[:invert] ? true : false)
     end
     redirect_to :action => 'browse', :phrs => params[:phrs]
   end

   def remove_facet
     session[:name_of_search] = nil
     for item in session[:constraints]
       if item[:fieldx] == params[:fieldx] && item[:value] == params[:value]
         session[:constraints].delete(item)
       end
      end
    redirect_to :action => 'browse', :phrs => params[:phrs]
   end

  def remove_genre
     session[:name_of_search] = nil
    for item in session[:constraints]
      if item[:fieldx] == 'genre' && item[:value] == params[:value]
        session[:constraints].delete(item)
      end
    end
    redirect_to :action => 'browse', :phrs => params[:phrs]
  end

   def remove_discipline
     session[:name_of_search] = nil
     for item in session[:constraints]
       if item[:fieldx] == 'discipline' && item[:value] == params[:value]
         session[:constraints].delete(item)
       end
     end
     redirect_to :action => 'browse', :phrs => params[:phrs]
   end

   def remove_format
     session[:name_of_search] = nil
     for item in session[:constraints]
       if item[:fieldx] == 'doc_type' && item[:value] == params[:value]
         session[:constraints].delete(item)
       end
     end
     redirect_to :action => 'browse', :phrs => params[:phrs]
   end
  
   def remove_constraint
     session[:name_of_search] = nil
      idx = params[:index].to_i
      if session[:constraints] && idx < session[:constraints].size
        session[:constraints].delete_at idx
      end
      redirect_to :action => 'browse', :phrs => params[:phrs]
   end
   
   def invert_constraint
     session[:name_of_search] = nil
      idx = params[:index].to_i
      if session[:constraints] && idx < session[:constraints].size
        constraint = session[:constraints][idx]
        constraint.inverted = !constraint.inverted
      end
      redirect_to :action => 'browse', :phrs => params[:phrs]
   end

    def new_search
      clear_constraints()
      if params[:mode] == 'typewright'
        session[:constraints] << TypeWrightConstraint.new(:inverted => false )  
      end
      redirect_to :action => 'browse'      
    end

		def list_name_facet_all
     @solr = Catalog.factory_create(session[:use_test_index] == "true")
 		 @name_facets = @solr.name_facet(session[:constraints])
			render :partial => 'list_name_facet_all'
		end
   
   private
	def clear_constraints
		session[:name_of_search] = nil
		#session[:selected_resource_facets] = FacetCategory.find( :all, :conditions => "type = 'FacetValue'").map { |facet| facet.value }
		# don't clear the current setting of the federation constraints.
		if session[:constraints]
			session[:constraints].delete_if { |constraint| !constraint.is_a?(FederationConstraint) }
		end
		session[:search_sort_by] = nil
		session[:search_sort_by_direction] = nil
	end
   
   def auto_complete(keyword, field = 'content')
     @solr = Catalog.factory_create(session[:use_test_index] == "true")
     @field = field
     @values = []
     if params['search'] && session[:constraints]
       begin
         results = @solr.auto_complete(@field, session[:constraints], keyword)
		results.each { |result|
			@values.push([result['item'], result['occurrences']])
		}
	   rescue  #Net::HTTPServerException => e
		 # don't do anything if this fails.
	   end
     end

     render :partial => 'suggest'
   end
   
   public   
   def auto_complete_for_search_university
      
      str = params['group']['university']+'%'
      matches = Group.find_by_sql ["select distinct university from groups where university like ?", str]
      @values = []
      matches.each { |match|
         @values.push( match.university )
      }
      render :partial => 'autocomplete'
   end
   
   def auto_complete_for_search_keyword
    auto_complete(params['search']['keyword']) if params['search']  # google bot will hit this without parameters, so check for that
    if !request.post? # Search bots will call this as a :get; this just keeps them from creating an error message.
      render :text => ''
    end
   end

   def auto_complete_for_search_phrase
    auto_complete(params['search']['phrase']) if params['search']  # google bot will hit this without parameters, so check for that
    if !request.post? # Search bots will call this as a :get; this just keeps them from creating an error message.
      render :text => ''
    end
   end

   def auto_complete_for_search_term
    auto_complete(params['search']['phrase']) if params['search']  # google bot will hit this without parameters, so check for that
    if !request.post? # Search bots will call this as a :get; this just keeps them from creating an error message.
      render :text => ''
    end
   end

   def auto_complete_for_title
    auto_complete(params['search']['phrase'], 'title') if params['search']  # google bot will hit this without parameters, so check for that
    if !request.post? # Search bots will call this as a :get; this just keeps them from creating an error message.
      render :text => ''
    end
   end

   def auto_complete_for_author
    auto_complete(params['search']['phrase'], 'author') if params['search']  # google bot will hit this without parameters, so check for that
    if !request.post? # Search bots will call this as a :get; this just keeps them from creating an error message.
      render :text => ''
    end
   end

   def auto_complete_for_editor
    auto_complete(params['search']['phrase'], 'editor') if params['search']  # google bot will hit this without parameters, so check for that
    if !request.post? # Search bots will call this as a :get; this just keeps them from creating an error message.
      render :text => ''
    end
   end

   def auto_complete_for_publisher
    auto_complete(params['search']['phrase'], 'publisher') if params['search']  # google bot will hit this without parameters, so check for that
    if !request.post? # Search bots will call this as a :get; this just keeps them from creating an error message.
      render :text => ''
    end
   end

   def auto_complete_for_year
    auto_complete(params['search']['phrase'], 'year') if params['search']  # google bot will hit this without parameters, so check for that
    if !request.post? # Search bots will call this as a :get; this just keeps them from creating an error message.
      render :text => ''
    end
   end

   def save_search
     name = params[:saved_search_name]
     if (session[:user] && name != nil && name.length > 0)  # see if the session has timed out since the last browser action, and the user actually inputted sometime.
       user = User.find_by_username(session[:user][:username])
       session[:name_of_search] = name
       saved_search = user.searches.find_or_create_by_name(name)

			 saved_search.sort_by = session[:search_sort_by]
			 saved_search.sort_dir = session[:search_sort_by_direction]
       # [{:value=>"rossetti", :invert=>false, :fieldx=>"archive"}, {:invert=>true, :expression=>"damsel"}]
       
       saved_search.constraints.clear
       session[:constraints].each do |c|
         saved_search.constraints << c.clone
       end
       saved_search.save!
     end
     
     render :partial => 'show_saved_search'
     #redirect_to :action => 'browse'
   end
   
   def saved
     user = User.find_by_username(params[:user])
     if user != nil # If the session didn't time out
       session[:constraints] = []
       session[:name_of_search] = params[:name]
  
       saved_search = user.searches.find_by_name(params[:name])
       if (saved_search)  # If we found the search that the user requested (normally, will always succeed)
				session[:search_sort_by] = saved_search.sort_by
				session[:search_sort_by_direction] = saved_search.sort_dir
         # Recreate the original search instead of adding a constraint of SavedSearchConstraint
         saved_search.constraints.each do |saved_constraint|
           if saved_constraint.is_a?(FreeCultureConstraint)
             session[:constraints] << FreeCultureConstraint.new(:inverted => false)
           elsif saved_constraint.is_a?(FullTextConstraint)
             session[:constraints] << FullTextConstraint.new(:inverted => false)
           elsif saved_constraint.is_a?(TypeWrightConstraint)
             session[:constraints] << TypeWrightConstraint.new(:inverted => false)
           elsif saved_constraint.is_a?(ExpressionConstraint)
             add_keyword_constraint(saved_constraint[:value], saved_constraint[:inverted])
           elsif saved_constraint.is_a?(FacetConstraint)
             session[:constraints] << FacetConstraint.new(:fieldx => saved_constraint[:fieldx], :value => saved_constraint[:value], :inverted => saved_constraint[:inverted])
           elsif saved_constraint.is_a?(FederationConstraint)
             session[:constraints] << FederationConstraint.new(:fieldx => saved_constraint[:fieldx], :value => saved_constraint[:value], :inverted => saved_constraint[:inverted])
           end  # if saved_constraint.is_a
         end  # end do
       end  # if saved_search
     end  # if the session didn't timeout
     redirect_to :action => 'browse'
   end
   
   def remove_saved_search
     if (session[:user])
       user = User.find_by_username(session[:user][:username])
       searches = user.searches
       saved_search = searches.find(params[:id])
  
       saved_search.destroy
     end
     
     redirect_to :back
   end

	 def remember_resource_toggle
		 session[:resource_toggle] ||= {}
		 dir = params[:dir]
		 id = params[:id]
		 if dir == 'close' && id != nil
			 session[:resource_toggle][id] = 'close'
		 end
		 if dir == 'open' && id != nil
			 session[:resource_toggle][id] = 'open'
		 end
		 render :text => ''	# this is just to keep from getting an error.
	 end

   private
   def search_solr(constraints, page, items_per_page, sort_by, direction)
     @solr = Catalog.factory_create(session[:use_test_index] == "true") if @solr == nil
		 sort_param = nil	# in case the sort_by was an unexpected value
		 sort_param = 'author_sort' if sort_by == 'Name'
		 sort_param = nil if sort_by == 'Relevancy'
		 sort_param = 'title_sort' if sort_by == 'Title'
		 sort_param = 'year_sort' if sort_by == 'Date'
		 sort_ascending = direction != 'Descending'
     return @solr.search(constraints, (page - 1) * items_per_page, items_per_page, sort_param, sort_ascending)
   end
   
  # This chooses which constraints are listed on the results page above the results.
  def marshall_listed_constraints()  
    idx = 0
    constraints_with_ids = []
    for constraint in session[:constraints]
      # record the original index in the constraints array, use this as an id
      constraints_with_ids << { :id => idx, :constraint => constraint } 
      idx = idx + 1
    end

    return constraints_with_ids # at the moment, we are showing all constraints.
  end
  
   # take the genre facet data and organize it for display
  def marshall_genre_data( unsorted_genres )
    return [] unless unsorted_genres
  
    # filter out unspecified genre facets
    unsorted_genres = unsorted_genres.select {|value, count| value != '<unspecified>' } 
    
    sorted_genres = unsorted_genres.sort {|a,b| a[0] <=> b[0]}  
    sorted_genres.map { |pair|  
      existing_constraints = session[:constraints].select { |constraint| constraint[:fieldx] == "genre" and constraint[:value] == pair[0] }
      { :value => pair[0], :count => pair[1], :exists => (existing_constraints.size>0) }
    }
  end

   # take the format facet data and organize it for display
   def marshall_format_data( unsorted_formats )
     return [] unless unsorted_formats

     # filter out unspecified formats facets
     unsorted_formats = unsorted_formats.select {|value, count| value != '<unspecified>' }

     sorted_formats = unsorted_formats.sort {|a,b| a[0] <=> b[0]}
     sorted_formats.map { |pair|
       existing_constraints = session[:constraints].select { |constraint| constraint[:fieldx] == "doc_type" and constraint[:value] == pair[0] }
       { :value => pair[0], :count => pair[1], :exists => (existing_constraints.size>0) }
     }
   end

   # take the discipline facet data and organize it for display
   def marshall_discipline_data( unsorted_discipline )
     return [] unless unsorted_discipline

     # filter out unspecified discipline facets
     unsorted_discipline = unsorted_discipline.select {|value, count| value != '<unspecified>' }

     sorted_discipline = unsorted_discipline.sort {|a,b| a[0] <=> b[0]}
     sorted_discipline.map { |pair|
       existing_constraints = session[:constraints].select { |constraint| constraint[:fieldx] == "discipline" and constraint[:value] == pair[0] }
       { :value => pair[0], :count => pair[1], :exists => (existing_constraints.size>0) }
     }
   end
  
end
