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
				render "index", { layout: 'application' }
			}
			format.json do
            if params.has_key? :pages
               begin
                  items_per_page = 30
                  page = 1
                  page = params[:pages_page]  if params[:pages_page].present?
                  @solr = Catalog.factory_create(session[:use_test_index] == "true") if @solr == nil
                  results = @solr.search_pages(params[:q], params[:pages], (page.to_i - 1) * items_per_page, items_per_page)
                  results['message'] = ''
               rescue Catalog::Error => e
                  results = rescue_search_error(e)
                  results['message'] = e.message
               end
            else
               items_per_page = 30
   				page = params[:page].present? ? params[:page] : 1
   				sort_param = params[:srt].present? ? params[:srt] : nil
   				sort_ascending = params[:dir].present? ? params[:dir] == 'asc' : true
   				constraints = process_constraints(params)
   				begin
   					@solr = Catalog.factory_create(session[:use_test_index] == "true") if @solr == nil
   					results = @solr.search_direct(constraints, (page.to_i - 1) * items_per_page, items_per_page, sort_param, sort_ascending)
   					results['message'] = ''
   				rescue Catalog::Error => e
   					results = rescue_search_error(e)
   					results['message'] = e.message
   				end
   		   end
				results['page_size'] = items_per_page

				# process all the returned hits to insert all non-solr info
				results['collected'] = view_context.add_non_solr_info_to_results(results['hits'], results["highlighting"])

				# This fixes the format of the access facet.
				results['facets']['access'] = {}
				results['facets']['access']['freeculture'] = results['facets']['freeculture']['true'] if results['facets']['freeculture'].present? && results['facets']['freeculture']['true'].present?
				results['facets']['access']['fulltext'] = results['facets']['has_full_text']['true'] if results['facets']['has_full_text'].present? && results['facets']['has_full_text']['true'].present?
				results['facets']['access']['ocr'] = results['facets']['ocr']['true'] if results['facets']['ocr'].present? && results['facets']['ocr']['true'].present?
				results['facets']['access']['typewright'] = results['facets']['typewright']['true'] if results['facets']['typewright'].present? && results['facets']['typewright']['true'].present?

				# Be sure that all the facets are returned, even if they are empty.
				results['facets']['genre'] = {} if results['facets']['genre'].blank?
				results['facets']['archive'] = {} if results['facets']['archive'].blank?
				results['facets']['federation'] = {} if results['facets']['federation'].blank?
				results['facets']['doc_type'] = {} if results['facets']['doc_type'].blank?
				results['facets']['discipline'] = {} if results['facets']['discipline'].blank?
				results['facets']['role'] = {} if results['facets']['role'].blank?
				render :json => results
			end
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
	   return constraints if query.blank?

	   legal_constraints = [ 'q', 'f', 'o', 'g', 'a', 't', 'aut', 'ed', 'pub', 'r_art', 'r_own', 'fuz_q', 'fuz_t', 'y', 'lang', 'doc_type', 'discipline', 'fuz_q', 'fuz_t' ]
	   @searchable_roles.each { |role|
		   legal_constraints.push(role[0])
	   }

	   found_federation = false
	   query.each { |key, val|
		   found_federation = true if key == 'f'
		   if legal_constraints.include?(key) && val.present?
			   if key == 'q' || key == 't' || key == 'aut' || key == 'pub' || key == 'ed' || key == 'r_own' || key == 'r_art'
				   val = process_q_param(val)
			   end
			   # if we were passed fuzzy constraints, make sure that the corresponding other value is set
			   if key == 'fuz_q'
				   constraints.push({key: key, val: "#{val.to_i-1}"}) if query['q']
			   elsif key == 'fuz_t'
				   constraints.push({key: key, val: "#{val.to_i-1}"}) if query['t']
			   else
				   constraints.push({key: key, val: val})
			   end
		   end
	   }
	   # if there is no federation constraint, we use the default federation.
	   if !found_federation
		   constraints.push({ key: 'f', val: Setup.default_federation() })
	   end
	   fuz = constraints.index('fuz_q')
	   if query
		   other = constraints.index('q')
		   constraints.delete(fuz) if !other
	   end

	   return constraints
   end

   def set_archive_toggle_state(archives)
	   archives.each { |archive|
		   if archive['children'].present?
			   if session[:resource_toggle].present? && session[:resource_toggle]["#{archive['id']}"].present? && session[:resource_toggle]["#{archive['id']}"] == 'open'
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
	 @searchable_roles = [
		 ["r_art", "Artist"],
		 ["aut", "Author"],
		 ["role_BND", "Binder"],
		 ["role_COL", "Collector"],
		 ["role_COM", "Compiler"],
		 ["role_CRE", "Creator"],
		 ["role_CTG", "Cartographer"],
		 ["ed", "Editor"],
		 ["role_ILU", "Illuminator"],
		 ["role_LTG", "Lithographer"],
		 ["r_own", "Owner"],
		 ["pub", "Publisher"],
		 ["role_POP", "Printer of plates"],
		 ["role_PRT", "Printer"],
		 ["role_RPS", "Repository"],
		 ["role_SCR", "Scribe"],
		 ["role_TRL", "Translator"],
		 ["role_WDE", "Wood Engraver"]
	 ]
	 return true
   end

   private

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
     flash[:error] = render_to_string(:inline => "You have entered a search string with invalid characters.  You should <%=link_to 'clear all your constraints', { :action => 'search' }, { :class => 'nav_link' } %> or remove the offending search string below.")

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
		query = params[:query]
		name = params[:saved_search_name]
		if user_signed_in? && name != nil && name.length > 0
			saved_search = current_user.searches.find_or_create_by_name(name)
			saved_search.url = query
			saved_search.save!
		end
		render json: { name: name, url: query }
   end

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
		 render :nothing=>true
	 end

   private
   def search_solr(constraints, page, items_per_page, sort_by, direction)
     @solr = Catalog.factory_create(session[:use_test_index] == "true") if @solr == nil
		 sort_param = nil	# in case the sort_by was an unexpected value
		 sort_param = 'author_sort' if sort_by == 'Name'
		 sort_param = nil if sort_by == 'Relevancy'
		 sort_param = 'title_sort' if sort_by == 'Title'
		 sort_param = 'year_sort' if sort_by == 'Date'
		 sort_ascending = direction != 'desc'
     return @solr.search(constraints, (page - 1) * items_per_page, items_per_page, sort_param, sort_ascending)
   end

end
