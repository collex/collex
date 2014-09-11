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
   #before_filter :authorize, :only => [:collect, :save_search, :remove_saved_search]
   before_filter :init_view_options
   def initialize

   end

	# /search
	# /search.json
	def index
		# When this is called as html, it just creates the blank search page and it will send back an ajax call for the search.
		# When this is called as json, it does the search.
		respond_to do |format|
			format.html {
				render "index", { layout: 'application' } # TODO-PER: Why does the layout have to be expressly defined?
			}
			format.json {
				items_per_page = 30
				page = params[:page].present? ? params[:page] : 1
				sort_param = params[:srt].present? ? params[:srt] : nil
				sort_ascending = params[:dir].present? ? params[:dir] == 'asc' : true
				constraints = process_constraints(params)
				begin
					@solr = Catalog.factory_create(session[:use_test_index] == "true") if @solr == nil
					@results = @solr.search_direct(constraints, (page.to_i - 1) * items_per_page, items_per_page, sort_param, sort_ascending)
					@results['message'] = ''
				rescue Catalog::Error => e
					@results = rescue_search_error(e)
					@results['message'] = e.message
				end

				# process all the returned hits to insert all non-solr info
				all_uris = []
				@results['hits'].each { |hit|
					# make a list of all uris so that we can find the collected ones and any annotations
					all_uris.push(hit['uri'])

					# Add the highlighting to the hit object so that a result is completely contained inside the hit object
					if @results["highlighting"] && hit['uri'] && @results["highlighting"][hit["uri"]]
						t = @results["highlighting"][hit["uri"]].to_s.strip()
						# We want to escape everything except the bolding so that random control chars can't mess up the display
						t = h(t.gsub('&', 'AmPeRsAnD'))
						hit['text'] = t.gsub("&lt;em&gt;", "<em>").gsub("&lt;/em&gt;", "</em>").gsub('AmPeRsAnD', '&')
					end

					# Add any referencing exhibits
					exhibits = Exhibit.get_referencing_exhibits(hit["uri"], current_user)
					hit['exhibits'] = exhibits if exhibits.length > 0
				}
				@results['page_size'] = items_per_page

				@results['collected'] = {}
				if user_signed_in? && all_uris.length > 0
					collected_items = CollectedItem.items_in_uri_list(get_curr_user_id(), all_uris)
					collected_items.each { |uri, item|
						@results['collected'][uri] = item[:updated_at]
						if item[:annotation].present?
							@results['hits'].each { |hit|
								if hit['uri'] == uri
									hit['annotation'] = view_context.decode_exhibit_links(item[:annotation])
								end
							}
						end
					}
				end

				if all_uris.length > 0
					my_tags, tags = Tag.items_in_uri_list(all_uris, get_curr_user_id)
					my_tags.each { |uri, name|
						@results['hits'].each { |hit|
							hit['my_tags'] = name if hit['uri'] == uri
						}
					}
					tags.each { |uri, name|
						@results['hits'].each { |hit|
							hit['tags'] = name if hit['uri'] == uri
						}
					}
				end

				# This fixes the format of the access facet.
				@results['facets']['access'] = {}
				@results['facets']['access']['freeculture'] = @results['facets']['freeculture']['true'] if @results['facets']['freeculture'].present? && @results['facets']['freeculture']['true'].present?
				@results['facets']['access']['fulltext'] = @results['facets']['has_full_text']['true'] if @results['facets']['has_full_text'].present? && @results['facets']['has_full_text']['true'].present?
				@results['facets']['access']['ocr'] = @results['facets']['ocr']['true'] if @results['facets']['ocr'].present? && @results['facets']['ocr']['true'].present?
				@results['facets']['access']['typewright'] = @results['facets']['typewright']['true'] if @results['facets']['typewright'].present? && @results['facets']['typewright']['true'].present?

				# Be sure that all the facets are returned, even if they are empty.
				@results['facets']['genre'] = {} if @results['facets']['genre'].blank?
				@results['facets']['archive'] = {} if @results['facets']['archive'].blank?
				@results['facets']['federation'] = {} if @results['facets']['federation'].blank?
				@results['facets']['doc_type'] = {} if @results['facets']['doc_type'].blank?
				@results['facets']['discipline'] = {} if @results['facets']['discipline'].blank?
				@results['facets']['role'] = {} if @results['facets']['role'].blank?
				render :json => @results
			}
		end
	end

   private
   def process_q_param(value)
	   # This will receive either a string or an array of strings.
	   # The strings need to be split on white space.
	   if value.kind_of?(Array)
		   value = value.join(' ')
	   end
	   arr = value.scan(/(?:"(?:\\.|[^"])*"|[^" ])+/) # this splits the string, but respects double quotes.
	   return arr
   end

   def process_constraints(query)
	   constraints = []
	   legal_constraints = [ 'q', 'f', 'o', 'g', 'a', 't', 'aut', 'ed', 'pub', 'r_art', 'r_own', 'fuz_q', 'fuz_t', 'y', 'lang', 'doc_type', 'discipline' ] # also the role_* ones

	   found_federation = false
	   query.each { |key, val|
		   found_federation = true if key == 'f'
		   if legal_constraints.include?(key) && val.present?
			   if key == 'q' || key == 't' || key == 'aut' || key == 'pub' || key == 'ed' || key == 'own' || key == 'art'
				   val = process_q_param(val)
			   end
			   constraints.push({ key: key, val: val })
		   end
	   }
	   # if there is no federation constraint, we use the default federation.
	   if !found_federation
		   constraints.push({ key: 'f', val: Setup.default_federation() })
	   end
	   return constraints
   end

   def set_archive_toggle_state(archives)
	   archives.each { |archive|
		   if archive['children'].present?
			   if session[:resource_toggle].present? && session[:resource_toggle]["#{archive['id']}"].present? && session[:resource_toggle]["#{archive['id']}"] == :open
				   archive['toggle'] = 'open'
			   else
				   archive['toggle'] = 'close'
			   end
			   set_archive_toggle_state(archive['children'])
		   end
	   }
   end

   def init_view_options
     @site_section = :search
	 @solr = Catalog.factory_create(session[:use_test_index] == "true")
	 @archives = @solr.get_resource_tree()
	 set_archive_toggle_state(@archives)
	 @other_federations = []
	 session[:federations].each { |key,val| @other_federations.push(key) if key != Setup.default_federation() } if session[:federations]
	 return true
   end

   private
   # def parse_keyword_phrase(phrase_str, invert)
   #   # This breaks the keyword phrase that the user entered into separate searches and adds each constraint separately.
   #
   #   # first, find quoted sections and replace spaces within them
   #   # with an '_' so they wont get split by regex
   #   start_pos = 0
   #   while true
   #     p1 = phrase_str.index("\"", start_pos)
   #     if p1.nil?
   #       break
   #     else
   #       p2 = phrase_str.index("\"", p1+1)
   #       if p2.nil?
   #         break
   #       else
   #         str = phrase_str[p1..p2]
   #         str.gsub!(/[\s\-]+/, "_")
   #         phrase_str = phrase_str[0...p1] + str + phrase_str[p2+1..-1]
   #         start_pos = p2+1
   #         if start_pos >= phrase_str.length
   #           break
   #         end
   #       end
   #     end
   #   end
   #
   #     # strip punctuation and other troublesome chars
   #     # NOTE: for some reason, the escaped brackets only work in ruby regex if
   #     # they are in the middle of the expression.
   #    phrase_str.gsub!(/[.\^&=@#\$%\*<>\/\?\|,\[\]!}{+-]/, " ")
   #
   #   # now, split the string on spaces
   #   words_arr = phrase_str.split(/[\s\-]+/)
   #
   #   # find AND and get rid of it
   #   words_arr.delete_if { |word| word.upcase == "AND" }
   #
   #   # NOT/OR cleanup pass through words:
   #   inverted = {}
   #   invert_next = false
   #   words_arr.each_with_index do |word, index|
   #
   #     if word.upcase == "NOT"
   #       # set a flag so the next word found will be inverted
   #       invert_next = true
   #       words_arr[index] = ""
   #     #elsif word.upcase == "OR"
   #     #  # when OR is found at non-terminal position stitch words
   #     #  if index > 0 && index < words_arr.length - 1
   #     #    # find the invert state of the current start of the OR
   #     #    prior_invert = inverted[ words_arr[index-1] ]
   #     #
   #     #    # stitch and clear words
   #     #    words_arr[index] = words_arr[index-1] + " OR " + words_arr[index+1]
   #     #    words_arr[index-1] = ""
   #     #    words_arr[index+1] = ""
   #     #
   #     #    # carry prior invert state on to the stitched result
   #     #    inverted[ words_arr[index] ] = prior_invert
   #     #  else
   #     #    words_arr[index] = ""
   #     #  end
   #     else
   #       # a preceding OR may have blanked this word out. skip it if so
   #       if word != ""
   #         inverted[word] = !invert if invert_next == true
   #         inverted[word] = invert if invert_next == false
   #         invert_next = false
   #       end
   #     end
   #   end
   #
   #   # Finally, create each constraint for non-empty strings
   #   words_arr.each do |word|
   #     if word != ""
	# 	   inv = inverted[word]
   #       word.gsub!("_", " ")
   #       add_keyword_constraint(word, inv )
   #     end
   #   end
   #
   # end

   # def add_keyword_constraint(phrase_str, invert)
   #     expression = phrase_str
   #     if expression and expression.strip.size > 0 && session[:constraints]
   #       session[:constraints] << ExpressionConstraint.new(:value => expression, :inverted => invert)
   #     end
   # end

   def add_keyword_fuz_constraint(phrase_str, invert)
     expression = phrase_str
     if expression and expression.strip.size > 0 and expression != '1' && session[:constraints]
       adjusted_val = "#{(expression.to_i-1)}"
       session[:constraints] << FacetConstraint.new(:fieldx => 'fuz_q', :value => adjusted_val, :inverted => invert)
     end
   end

   def modify_keyword_fuz_constraint(phrase_str, invert, constraint)
     expression = phrase_str
     if expression and expression.strip.size > 0 and expression != '1' && constraint
       constraint[:value] = "#{(expression.to_i-1)}"
       constraint[:inverted] = invert
     elsif session[:constraints]
       session[:constraints].delete(constraint)
     end
   end

   # def add_title_constraint(phrase_str, invert)
   #     expression = phrase_str
   #     if expression and expression.strip.size > 0 && session[:constraints]
   #       session[:constraints] << FacetConstraint.new(:fieldx => 'title', :value => phrase_str, :inverted => invert)
   #     end
   # end

   def modify_title_fuz_constraint(phrase_str, invert, constraint)
     expression = phrase_str
     if expression and expression.strip.size > 0 and expression != '1' && constraint
       constraint[:value] = "#{(expression.to_i-1)}"
       constraint[:inverted] = invert
     elsif session[:constraints]
       session[:constraints].delete(constraint)
     end
   end

   def add_title_fuz_constraint(phrase_str, invert)
     expression = phrase_str
     if expression and expression.strip.size > 0 and expression != '1' && session[:constraints]
       session[:constraints] << FacetConstraint.new(:fieldx => 'fuz_t', :value =>  "#{(expression.to_i-1)}", :inverted => invert)
     end
   end

  # def add_date_constraint(phrase_str, invert)
  #    if (phrase_str and not phrase_str.strip.empty?) && session[:constraints]
  #      session[:constraints] << FacetConstraint.new(:fieldx => 'year', :value => phrase_str, :inverted => invert)
  #    end
  # end

  # def add_author_constraint(phrase_str, invert)
  #   if phrase_str and phrase_str.strip.size > 0 && session[:constraints]
  #      session[:constraints] << FacetConstraint.new(:fieldx => 'author', :value => phrase_str, :inverted => invert)
  #   end
  # end

  # def add_artist_constraint(phrase_str, invert)
  #   if phrase_str and phrase_str.strip.size > 0 && session[:constraints]
  #     session[:constraints] << FacetConstraint.new(:fieldx => 'r_art', :value => phrase_str, :inverted => invert)
  #   end
  # end
  #
  # def add_owner_constraint(phrase_str, invert)
  #   if phrase_str and phrase_str.strip.size > 0 && session[:constraints]
  #     session[:constraints] << FacetConstraint.new(:fieldx => 'r_own', :value => phrase_str, :inverted => invert)
  #   end
  # end
  #
  # def add_editor_constraint(phrase_str, invert)
  #   if phrase_str and phrase_str.strip.size > 0 && session[:constraints]
  #      session[:constraints] << FacetConstraint.new(:fieldx => 'editor', :value => phrase_str, :inverted => invert)
  #   end
  # end
  #
  #  def add_role_constraint(role, phrase_str, invert)
  #    if phrase_str and phrase_str.strip.size > 0 && session[:constraints]
  #      session[:constraints] << FacetConstraint.new(:fieldx => role, :value => phrase_str, :inverted => invert)
  #    end
  #  end
  #
  # def add_publisher_constraint(phrase_str, invert)
  #   if phrase_str and phrase_str.strip.size > 0 && session[:constraints]
  #      session[:constraints] << FacetConstraint.new(:fieldx => 'publisher', :value => phrase_str, :inverted => invert)
  #   end
  # end

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
       flash[:error] = render_to_string(:inline => "You have entered a search string with invalid characters.  You should <%=link_to 'clear all your constraints', { :action => 'search' }, { :class => 'nav_link' } %> or remove the offending search string below.")
     end
     return {"facets" => {"archive" => {}, "freeculture" => {}, "genre" => {}}, "total_hits" => 0, "hits" => [], "total_documents" => 0}
  end

   def get_resource_tree
		return session[:resource_tree].blank? ? @solr.get_resource_tree() : session[:resource_tree]
   end

    public

	def list_name_facet_all
		search_params = params[:query]
		search_params = process_constraints(search_params)
		@solr = Catalog.factory_create(session[:use_test_index] == "true")
		@name_facets = @solr.name_facet(search_params)
		render :partial => 'list_name_facet_all'
	end

   private
   def auto_complete(keyword, field, existing_search)
	   @solr = Catalog.factory_create(session[:use_test_index] == "true")
	   values = []
	   begin
		   results = @solr.auto_complete(field, existing_search, keyword)
		   if results.present? # This can be nil in a normal case, when there are no matches.
			   results.each { |result|
				   values.push([result['item'], result['occurrences']])
			   }
		   end
	   rescue Net::HTTPServerException => e
		   logger.error("Autocomplete error: #{e.message}")
		   # don't do anything if this fails.
	   end
	   return values
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

   def auto_complete_for_q
	   other = params[:other]
	   other = process_constraints(other)
	   field = params[:field]
	   if field.nil? || field == 'q'
	   	field = 'content'
	   elsif field == 'aut'
		   field = 'author'
	   elsif field == 't'
		   field = 'title'
	   elsif field == 'ed'
		   field = 'editor'
	   elsif field == 'pub'
		   field = 'publisher'
		end
	   respond_to do |format|
		   format.json {
			   values = auto_complete(params['term'], field, other) if params['term']  # google bot will hit this without parameters, so check for that
			   render json: values
		   }
	   end
    end

    def save_search
		query = URI.unescape(params[:query])
		query = query.gsub("%20", ' ')
		name = params[:saved_search_name]
		if user_signed_in? && name != nil && name.length > 0
			saved_search = current_user.searches.find_or_create_by_name(name)
			saved_search.url = query
			saved_search.save!
		end
		render json: { name: name, url: query }
   end

   # def saved
   #   if user_signed_in?
   #     session[:constraints] = []
   #     session[:name_of_search] = params[:name]
   #
   #     saved_search = user.searches.find_by_name(params[:name])
   #     if (saved_search)  # If we found the search that the user requested (normally, will always succeed)
	# 			session[:search_sort_by] = saved_search.sort_by
	# 			session[:search_sort_by_direction] = saved_search.sort_dir
   #       # Recreate the original search instead of adding a constraint of SavedSearchConstraint
   #       saved_search.constraints.each do |saved_constraint|
   #         if saved_constraint.is_a?(FreeCultureConstraint)
   #           session[:constraints] << FreeCultureConstraint.new(:inverted => false)
   #         elsif saved_constraint.is_a?(FullTextConstraint)
   #           session[:constraints] << FullTextConstraint.new(:inverted => false)
   #         elsif saved_constraint.is_a?(TypeWrightConstraint)
   #           session[:constraints] << TypeWrightConstraint.new(:inverted => false)
   #         elsif saved_constraint.is_a?(ExpressionConstraint)
   #           add_keyword_constraint(saved_constraint[:value], saved_constraint[:inverted])
   #         elsif saved_constraint.is_a?(FacetConstraint)
   #           session[:constraints] << FacetConstraint.new(:fieldx => saved_constraint[:fieldx], :value => saved_constraint[:value], :inverted => saved_constraint[:inverted])
   #         elsif saved_constraint.is_a?(FederationConstraint)
   #           session[:constraints] << FederationConstraint.new(:fieldx => saved_constraint[:fieldx], :value => saved_constraint[:value], :inverted => saved_constraint[:inverted])
   #         end  # if saved_constraint.is_a
   #       end  # end do
   #     end  # if saved_search
   #   end  # if the session didn't timeout
   #   redirect_to :action => 'browse'
   # end

   def remove_saved_search
     if user_signed_in?
       searches = current_user.searches
       saved_search = searches.find_by_id(params[:id])
	   saved_search = searches.find_by_name(params[:id]) if saved_search.blank?
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
  # def marshall_listed_constraints()
  #   idx = 0
  #   constraints_with_ids = []
  #   for constraint in session[:constraints]
  #     # record the original index in the constraints array, use this as an id
  #     constraints_with_ids << { :id => idx, :constraint => constraint }
  #     idx = idx + 1
  #   end
  #
  #   return constraints_with_ids # at the moment, we are showing all constraints.
  # end
  #
  #  # take the genre facet data and organize it for display
  # def marshall_genre_data( unsorted_genres )
  #   return [] unless unsorted_genres
  #
  #   # filter out unspecified genre facets
  #   unsorted_genres = unsorted_genres.select {|value, count| value != '<unspecified>' }
  #
  #   sorted_genres = unsorted_genres.sort {|a,b| a[0] <=> b[0]}
  #   sorted_genres.map { |pair|
  #     existing_constraints = session[:constraints].select { |constraint| constraint[:fieldx] == "genre" and constraint[:value] == pair[0] }
  #     { :value => pair[0], :count => pair[1], :exists => (existing_constraints.size>0) }
  #   }
  # end
  #
  #  # take the format facet data and organize it for display
  #  def marshall_format_data( unsorted_formats )
  #    return [] unless unsorted_formats
  #
  #    # filter out unspecified formats facets
  #    unsorted_formats = unsorted_formats.select {|value, count| value != '<unspecified>' }
  #
  #    sorted_formats = unsorted_formats.sort {|a,b| a[0] <=> b[0]}
  #    sorted_formats.map { |pair|
  #      existing_constraints = session[:constraints].select { |constraint| constraint[:fieldx] == "doc_type" and constraint[:value] == pair[0] }
  #      { :value => pair[0], :count => pair[1], :exists => (existing_constraints.size>0) }
  #    }
  #  end
  #
  #  # take the discipline facet data and organize it for display
  #  def marshall_discipline_data( unsorted_discipline )
  #    return [] unless unsorted_discipline
  #
  #    # filter out unspecified discipline facets
  #    unsorted_discipline = unsorted_discipline.select {|value, count| value != '<unspecified>' }
  #
  #    sorted_discipline = unsorted_discipline.sort {|a,b| a[0] <=> b[0]}
  #    sorted_discipline.map { |pair|
  #      existing_constraints = session[:constraints].select { |constraint| constraint[:fieldx] == "discipline" and constraint[:value] == pair[0] }
  #      { :value => pair[0], :count => pair[1], :exists => (existing_constraints.size>0) }
  #    }
  #  end

end
