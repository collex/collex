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
   layout 'collex_tabs'
   #before_filter :authorize, :only => [:collect, :save_search, :remove_saved_search]
   before_filter :init_view_options
   
   # Number of search results to display by default
   MIN_ITEMS_PER_PAGE = 10
   MAX_ITEMS_PER_PAGE = 30
   
   def initialize
      @solr = CollexEngine.new(COLLEX_ENGINE_PARAMS)
   end
   
   private
   def init_view_options
     @use_tabs = true
     @use_signin= true
     @site_section = :search
     return true
   end
   public
   
#   def do_basic_search
#     add_keyword_constraint(params[:search_phrase])
#     redirect_to :action => 'browse'
#   end
   
   def add_constraint
     session[:name_of_search] = nil
      # There are two types of input we can receive here, depending on whether the search form was expanded.
      # There might be a different input box for each type of search, or there might be a single input box with a select field determining the type.

      if params[:search_phrase]
        # basic search
        # We were called from the home page, so make sure there aren't any constraints laying around
        clear_constraints()
        parse_keyword_phrase(params[:search_phrase])
        
      elsif params[:search][:phrase] == nil
        # expanded input boxes
        parse_keyword_phrase(params[:search][:keyword]) if params[:search] && params[:search][:keyword] != ""
        add_title_constraint(params[:search_title]) if params[:search_title] != ""
        add_keyword_constraint(params[:search_author]) if params[:search_author] != ""
        add_keyword_constraint(params[:search_editor]) if params[:search_editor] != ""
        add_keyword_constraint(params[:search_publisher]) if params[:search_publisher] != ""
        # add_author_constraint(params[:search_author]) if params[:search_author] != ""
        # add_editor_constraint(params[:search_editor]) if params[:search_editor] != ""
        # add_publisher_constraint(params[:search_publisher]) if params[:search_publisher] != ""
        add_date_constraint(params[:search_year]) if params[:search_year] != ""

      else
        # single input box
        parse_keyword_phrase(params[:search][:phrase]) if params[:search_type] == "Keyword"
        add_title_constraint(params[:search][:phrase]) if params[:search_type] == "Title"
        add_keyword_constraint(params[:search][:phrase]) if params[:search_type] == "Author"
        add_keyword_constraint(params[:search][:phrase]) if params[:search_type] == "Editor"
        add_keyword_constraint(params[:search][:phrase]) if params[:search_type] == "Publisher"
        # add_author_constraint(params[:search][:phrase]) if params[:search_type] == "Author"
        # add_editor_constraint(params[:search][:phrase]) if params[:search_type] == "Editor"
        # add_publisher_constraint(params[:search][:phrase]) if params[:search_type] == "Publisher"
        add_date_constraint(params[:search][:phrase]) if params[:search_type] == "Year"
      end

     redirect_to :action => 'browse'
   end
   
   private
   def parse_keyword_phrase(phrase_str)
     # This breaks the keyword phrase that the user entered into separate searches and adds each constraint separately.

     # look for "and" and throw it away. 
     # Take each separate word and create separate constraints, except:
     # keep NOT with next word and 
     # keep the word before and after OR.
     # Also, keep quoted substrings together.
     
     # To parse, we want to first divide the string non-destructively on both spaces and quotes (leaving both in the resulting array)
     #words_arr = phrase_str.split(/ |\"/)
     words_arr = phrase_str.scan %r{"[^"]*"|\S+}

     # find AND and get rid of it
     words_arr.each_with_index { |word, index|
       if word.upcase == "AND"
         words_arr[index] = ""
       end
     }
     words_arr = words_arr.select { |word| word != "" }
     
     # find OR and stitch them together. Ignore the ones at the beginning and ends of the array, though.
     or_indexes = []
     words_arr.each_with_index { |word, i|
       if i > 0 && i < words_arr.length - 1 && word.upcase == 'OR'
         or_indexes.insert(-1, i)
       end
     }
     or_indexes.each { |index|
       words_arr[index-1] = words_arr[index-1] + " OR " + words_arr[index+1]
       words_arr[index] = ""
       words_arr[index+1] = ""
     }
     words_arr = words_arr.select { |word| word != "" }
     
     # find NOT and put it with the next word
     not_indexes = []
     words_arr.each_with_index { |word, i|
       if i < words_arr.length - 1 && word.upcase == 'NOT'
         not_indexes.insert(-1, i)
       end
     }
     not_indexes.each { |index|
       words_arr[index] = "NOT " + words_arr[index+1]
       words_arr[index+1] = ""
     }
     words_arr = words_arr.select { |word| word != "" }

      # Finally, create each constraint
     words_arr.each { |word|
        add_keyword_constraint(word)
    }

   end
   
   def add_keyword_constraint(phrase_str)
       expression = phrase_str
       if expression and expression.strip.size > 0
         session[:constraints] << ExpressionConstraint.new(:value => expression)
       end
   end
 
   def add_title_constraint(phrase_str)
       expression = phrase_str
       if expression and expression.strip.size > 0
         session[:constraints] << FacetConstraint.new(:field => 'title', :value => phrase_str, :inverted => false)
       end
   end
 
  def add_date_constraint(phrase_str)
     if phrase_str and not phrase_str.strip.empty?
       session[:constraints] << FacetConstraint.new(:field => 'year', :value => phrase_str, :inverted => false)
     end
  end
  
  def add_author_constraint(phrase_str)
    if phrase_str and phrase_str.strip.size > 0
       session[:constraints] << FacetConstraint.new(:field => 'author', :value => phrase_str, :inverted => false)
    end
  end

  def add_editor_constraint(phrase_str)
    if phrase_str and phrase_str.strip.size > 0
       session[:constraints] << FacetConstraint.new(:field => 'editor', :value => phrase_str, :inverted => false)
    end
  end

  def add_publisher_constraint(phrase_str)
    if phrase_str and phrase_str.strip.size > 0
       session[:constraints] << FacetConstraint.new(:field => 'publisher', :value => phrase_str, :inverted => false)
    end
  end

  def rescue_search_error(e)
     error_message = e.message
     if (match = error_message.match( /Query_parsing_error_/ ))
       error_message = match.post_match
     else
       error_message = error_message.gsub(/^\d\d\d \"(.*)\"/,'\1')
     end
     if session[:constraints].length == 1 && session[:constraints][0]['type'] == "ExpressionConstraint"
       flash[:error] = render_to_string(:inline => "The search string \"#{session[:constraints][0]['value']}\" contains invalid characters. Try another search.")
     else
       flash[:error] = render_to_string(:inline => "You have entered a search string with invalid characters.  You should <%=link_to 'clear all your constraints', :action => 'new_search' %> or remove the offending search string below.")
     end 
     return {"facets" => {"archive" => {}, "freeculture" => {}, "genre" => {}}, "total_hits" => 0, "hits" => [], "total_documents" => 0}
  end
  
    public
  
   # generate search results based on constraints
   def browse     
    session[:constraints] ||= []
    session[:items_per_page] ||= MIN_ITEMS_PER_PAGE
    session[:selected_resource_facets] ||= FacetCategory.find( :all, :conditions => "type = 'FacetValue'").map { |facet| facet.value }
    #session[:selected_freeculture] ||= false

    @page = params[:page] ? params[:page].to_i : 1
    
    begin
     @results = search_solr(session[:constraints], @page, session[:items_per_page])
     # Add the highlighting to the hit object so that a result is completely contained inside the hit object
     @results['hits'].each { |hit|
       if @results["highlighting"] && hit['uri'] && @results["highlighting"][hit["uri"]]
         hit['text'] = @results["highlighting"][hit["uri"]]["text"] 
       end
     }
     
     # Now repeat the search without any resource type constraints, so we can get the resource totals.
     # The resource totals should stay the same whether the user has constrained by resources or not.
     resourceless_constraints = []
     session[:constraints].each {|constraint|
      if constraint[:field] != 'archive' || constraint[:type] != 'FacetConstraint'
        resourceless_constraints.insert(-1, constraint)
      end
     }
     if session[:constraints].length != resourceless_constraints.length # don't bother with the second search unless there was something filtered out above.
       resourceless_results = search_solr(resourceless_constraints, @page, session[:items_per_page])
       @results['facets']['archive'] = resourceless_results['facets']['archive']
     end
    rescue  Net::HTTPServerException => e
     @results = rescue_search_error(e)
    end

    @num_pages = @results["total_hits"].to_i.quo(session[:items_per_page]).ceil      
    @total_documents = @results["total_documents"]     
    @sites_forest = FacetCategory.sorted_facet_tree()
    @genre_data = marshall_genre_data(@results["facets"]["genre"])
    @citation_count = @results['facets']['genre']['Citation'] || 0
    @freeculture_count = @results['facets']['freeculture']['<unspecified>'] || 0
    @listed_constraints = marshall_listed_constraints() 
    
    render :action => 'results'
   end
   
   # adjust the number of search results per page
   def result_count
     session[:items_per_page] ||= MIN_ITEMS_PER_PAGE
     requested_items_per_page = params['search'] ? params['search']['result_count'].to_i : session[:items_per_page] 
     session[:items_per_page] = (requested_items_per_page <= MAX_ITEMS_PER_PAGE) ? requested_items_per_page : MAX_ITEMS_PER_PAGE
     redirect_to :action => 'browse'
   end
   
   # allows queries to be linked in directly, or typed into the browser directly
#   def search
#     session[:constraints] = [ExpressionConstraint.new(:value => params[:q])]
#     browse
#   end
   
   # The following entry points don't have any controller work needed, but are included so that all legal entry points are represented by a controller method.
   def news #TODO: This will move when we implement the feature
   end
   
   def results  # TODO: This should only be called by an internal redirect. Is there a danger in having this exposed to someone typing it in their browser?
   end
   
   def tab_about #TODO: This will move when we implement the feature
   end
   
   # constrain search to only return free culture objects 
   def constrain_freeculture
     if params[:remove] == 'true'
       session[:constraints].each {|constraint|
         if constraint[:type] == 'FreeCultureConstraint'
           session[:constraints].delete(constraint)
           break
         end
       }
     else
       session[:constraints] << FreeCultureConstraint.new(:inverted => true )
     end
   
#     if params[:freeculture] 
#       session[:selected_freeculture] = true 
#       existing_freeculture_constraint = session[:constraints].select { |constraint| constraint.is_a?(FreeCultureConstraint) } 
#       session[:constraints] << FreeCultureConstraint.new(:inverted => true) unless existing_freeculture_constraint.size > 0
#     else
#       session[:selected_freeculture] = false
#       existing_freeculture_constraint = session[:constraints].select { |constraint| constraint.is_a?(FreeCultureConstraint) } 
#       existing_freeculture_constraint.each { |constraint| session[:constraints].delete constraint } if existing_freeculture_constraint.size > 0       
#     end
     
     redirect_to :action => 'browse'
   end
   
   # constrains the search by the specified resources
   def constrain_resources
     
     resource = params[:resource]
     if params[:remove] == 'true'
       session[:constraints].each {|constraint|
         if constraint[:field] == 'archive' && constraint[:type] == 'FacetConstraint' && constraint[:value] == resource
           session[:constraints].delete(constraint)
           break
         end
       }
     else
       # Delete any previous resource constraint
       session[:constraints].each {|constraint|
         if constraint[:field] == 'archive' && constraint[:type] == 'FacetConstraint'
           session[:constraints].delete(constraint)
           break
         end
       }
       session[:constraints] << FacetConstraint.new( :field => 'archive', :value => resource, :inverted => false )
     end
     
#     # this is the list of things that are checked
#     checked_facets = params[:constrain_resources] ? params[:constrain_resources].keys : []
#
#     # we don't want to negatively constrain on items that are checked, so remove any such constraints
#     checked_facets.each { |facet| 
#       existing_facet_constraints = session[:constraints].select { |constraint| constraint.is_negative_facet_constraint?(facet) } 
#       existing_facet_constraints.each { |constraint| session[:constraints].delete constraint }
#     }
#
#     # checkboxes don't give us a list of what is not checked, so we have to figure that out
#     all_facets = FacetCategory.find( :all, :conditions => "type = 'FacetValue'").map { |facet| facet.value }
#     unchecked_facets = all_facets - checked_facets
#     
#     # add a negative facet constraint for each unchecked item
#     unchecked_facets.each { |facet|
#       existing_facet_constraints = session[:constraints].select { |constraint| constraint.is_negative_facet_constraint?(facet) } 
#       session[:constraints] << FacetConstraint.new( :field => 'archive', :value => facet, :inverted => true ) unless existing_facet_constraints.size > 0
#     }
#     
#     # record which facets have been selected
#     session[:selected_resource_facets] = checked_facets
#     
     redirect_to :action => 'browse'
   end
   
   def add_facet
     if params[:field] and params[:value]
       session[:constraints] << FacetConstraint.new(:field => params[:field], :value => params[:value], :inverted => params[:invert] ? true : false)
     end
     redirect_to :action => 'browse'
   end

  def remove_genre
    for item in session[:constraints]
      if item[:field] == 'genre' && item[:value] == params[:value]
        session[:constraints].delete(item)
      end
    end
    redirect_to :action => 'browse'
  end
  
   def remove_constraint
      idx = params[:index].to_i
      if idx < session[:constraints].size
        session[:constraints].delete_at idx
      end
      redirect_to :action => 'browse'
   end
   
   def invert_constraint
      idx = params[:index].to_i
      if idx < session[:constraints].size
        constraint = session[:constraints][idx]
        constraint.inverted = !constraint.inverted
      end
      redirect_to :action => 'browse'
   end

#   def new_expression
#     session[:constraints] = []
#     add_expression
#   end
   
#   def add_expression
#     if params['field'] and params['field']['content']
#       expression = params['field']['content']
#       if expression and expression.strip.size > 0
#         session[:constraints] << ExpressionConstraint.new(:value => expression)
#       end
#     end
#     redirect_to :action => 'browse'
#   end

    def new_search
      clear_constraints()
      redirect_to :action => 'browse'      
    end
   
   private
   def clear_constraints
    session[:name_of_search] = nil
    session[:selected_resource_facets] = FacetCategory.find( :all, :conditions => "type = 'FacetValue'").map { |facet| facet.value }
    #session[:selected_freeculture] = false
    session[:constraints] = []
   end
   
   public
   def auto_complete_for_search_keyword
     @field = 'content'
     @values = []
     if params['search']
       result = @solr.facet(@field, session[:constraints], params['search']['keyword'])
       @values = result.sort {|a,b| b[1] <=> a[1]}
     end
     
     render :partial => 'suggest'
   end

   def auto_complete_for_search_phrase
     @field = 'content'
     @values = []
     if params['search']
       result = @solr.facet(@field, session[:constraints], params['search']['phrase'])
       @values = result.sort {|a,b| b[1] <=> a[1]}
     end
     
     render :partial => 'suggest'
   end
#   def auto_complete_for_field_year
#     # TODO
#     @field = 'year'
#     @values = []
#     if params['field']
#       result = @solr.facet(@field, session[:constraints], params['field']['year'])
#       @values = result.sort {|a,b| b[1] <=> a[1]}
#     end
#     
#     render :partial => 'suggest'
#   end
   
#   def auto_complete_for_agent_name
#     # TODO
#     @values = []
#     if params['agent']
#       @values = @solr.agent_suggest(session[:constraints], params['agent']['name'])
#     end
#
#     render :partial => 'agents'
#   end   
   
#   def suggest
#     render :layout => 'bare'
#   end
   
   def save_search
     if (session[:user])  # see if the session has timed out since the last browser action
       user = User.find_by_username(session[:user][:username])
       name = params[:save_name]
       session[:name_of_search] = name
       saved_search = user.searches.find_or_create_by_name(name)
  
       # [{:value=>"rossetti", :invert=>false, :field=>"archive"}, {:invert=>true, :expression=>"damsel"}]
       
       saved_search.constraints.clear
       session[:constraints].each do |c|
         saved_search.constraints << c.clone
       end
       saved_search.save!
     end
     
     redirect_to :action => 'browse'
   end
   
   def apply_saved_search
     if (session[:user])
       user = User.find_by_username(session[:user][:username])
       session[:constraints] = []
       session[:name_of_search] = params[:name]

       saved_search = user.searches.find_by_name(params[:name])
       if (saved_search)
         # Recreate the original search instead of adding a constraint of SavedSearchConstraint
         saved_search.constraints.each do |saved_constraint|
           if saved_constraint.is_a?(FreeCultureConstraint)
             session[:constraints] << FreeCultureConstraint.new(:inverted => true)
           elsif saved_constraint.is_a?(ExpressionConstraint)
             add_keyword_constraint(saved_constraint[:value])
           elsif saved_constraint.is_a?(FacetConstraint)
             session[:constraints] << FacetConstraint.new(:field => saved_constraint[:field], :value => saved_constraint[:value], :inverted => saved_constraint[:inverted])
           end
         end
       end
     end
     #session[:constraints] << SavedSearchConstraint.new(:field => params[:username], :value => params[:name], :inverted => params[:invert] ? true : false)
     redirect_to :action => 'browse'
   end
   
#   def saved_permalink
#     user = User.find_by_username(params[:username])
#     saved_search = user.searches.find_by_name(params[:name]) unless user.nil?
#     
#     if saved_search
#       session[:constraints] = []
#       saved_search.constraints.each do |saved_constraint|
#         session[:constraints] << saved_constraint
#       end
#     else
#       flash[:error] = 'Saved search not found.'
#     end
#     browse
#   end
   
   def remove_saved_search
     if (session[:user])
       user = User.find_by_username(session[:user][:username])
       searches = user.searches
       saved_search = searches.find(params[:id])
  
       session[:constraints].delete_if {|item| item.is_a?(SavedSearchConstraint) && item.field == session[:user][:username] && item.value == saved_search.name }
       
       saved_search.destroy
     end
     
     redirect_to :action => 'browse'
   end
   
#   def edit_saved_search
#     session[:constraints] = []
#     saved_search = User.find_by_username(session[:user][:username]).searches.find(params[:id])
#     saved_search.constraints.each do |saved_constraint|
#       session[:constraints] << saved_constraint
#     end
#     redirect_to :action => 'browse'      
#   end

   private
   def search_solr(constraints, page, items_per_page)
     return @solr.search(constraints, (page - 1) * items_per_page, items_per_page)        
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

    # We only want to display expressions and genres.
    # FreeCultureConstraint is derived from ExpressionConstraint, so we have to filter that out explicitly
#    constraints_with_ids.select { |constraint| 
#      !constraint[:constraint].is_a?(FreeCultureConstraint) and
#      (constraint[:constraint].is_a?(ExpressionConstraint) or 
#      (constraint[:constraint].is_a?(FacetConstraint) and constraint[:constraint][:field] == 'genre') )
#    }
    return constraints_with_ids # at the moment, we are showing all constraints.
  end
  
   # take the genre facet data and organize it for display
  def marshall_genre_data( unsorted_genres )
    return [] unless unsorted_genres
  
    # filter out unspecified genre facets
    unsorted_genres = unsorted_genres.select {|value, count| value != '<unspecified>' } 
    
    sorted_genres = unsorted_genres.sort {|a,b| a[0] <=> b[0]}  
    sorted_genres.map { |pair|  
      existing_constraints = session[:constraints].select { |constraint| constraint[:field] == "genre" and constraint[:value] == pair[0] }
      { :value => pair[0], :count => pair[1], :exists => (existing_constraints.size>0) }
    }
  end
  
end
