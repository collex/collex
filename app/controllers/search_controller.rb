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
   MIN_ITEMS_PER_PAGE = 5
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

      phrase = params[:search_phrase]
      if phrase == nil
        # expanded input boxes
        add_keyword_constraint(params[:search][:keyword]) if params[:search] && params[:search][:keyword] != ""
        add_keyword_constraint(params[:search_author]) if params[:search_author] != ""
        add_keyword_constraint(params[:search_editor]) if params[:search_editor] != ""
        add_keyword_constraint(params[:search_publisher]) if params[:search_publisher] != ""
        add_date_constraint(params[:search_year]) if params[:search_year] != ""
      elsif params[:search_type] == nil
        # basic search
        # We were called from the home page, so make sure there aren't any constraints laying around
        clear_constraints()
        add_keyword_constraint(params[:search_phrase])
      else
        # single input box
        add_keyword_constraint(params[:search][:phrase]) if params[:search_type] == "Keyword"
        add_keyword_constraint(params[:search][:phrase]) if params[:search_type] == "Author"
        add_keyword_constraint(params[:search][:phrase]) if params[:search_type] == "Editor"
        add_keyword_constraint(params[:search][:phrase]) if params[:search_type] == "Publisher"
        add_date_constraint(params[:search][:phrase]) if params[:search_type] == "Year"
      end

     redirect_to :action => 'browse'
   end
   
   private
   def add_keyword_constraint(phrase_str)
       expression = phrase_str
       if expression and expression.strip.size > 0
         session[:constraints] << ExpressionConstraint.new(:value => expression)
       end
   end
 
  def add_date_constraint(phrase_str)
     if phrase_str and not phrase_str.strip.empty?
       session[:constraints] << FacetConstraint.new(:field => 'year', :value => phrase_str, :inverted => false)
     end
  end
  
  def add_author_constraint(phrase_str)
    if phrase_str and phrase_str.strip.size > 0
       session[:constraints] << FacetConstraint.new(:field => 'agent', :value => phrase_str, :inverted => false)
    end
  end

  def rescue_search_error(e)
     error_message = e.message
     if (match = error_message.match( /Query_parsing_error_/ ))
       error_message = match.post_match
     else
       error_message = error_message.gsub(/^\d\d\d \"(.*)\"/,'\1')
     end
     if session[:constraints].length == 1
       if params[:search_phrase] != ""
         flash[:error] = render_to_string(:inline => "The search string \"#{params[:search_phrase]}\" contains invalid characters. Try another search.")
       end
       new_search
     else
       flash[:error] = render_to_string(:inline => "You have entered a search string with invalid characters.  You should <%=link_to 'clear all your constraints', :action => 'new_search' %> or remove the offending search string below.")
     end 
     return {"facets" => {"archive" => {}}, "total_hits" => 0}
  end
  
    public
  
   # generate search results based on constraints
   def browse     
    session[:constraints] ||= []
    session[:items_per_page] ||= MIN_ITEMS_PER_PAGE
    session[:selected_resource_facets] ||= FacetCategory.find( :all, :conditions => "type = 'FacetValue'").map { |facet| facet.value }
    session[:selected_freeculture] ||= false

    @page = params[:page] ? params[:page].to_i : 1
    
    begin
     @results = search_solr(session[:constraints], @page, session[:items_per_page])
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
   
   def tags #TODO: This will move when we implement the feature
   end
   
   # constrain search to only return free culture objects 
   def constrain_freeculture
     if params[:freeculture] 
       session[:selected_freeculture] = true 
       existing_freeculture_constraint = session[:constraints].select { |constraint| constraint.is_a?(FreeCultureConstraint) } 
       session[:constraints] << FreeCultureConstraint.new(:inverted => true) unless existing_freeculture_constraint.size > 0
     else
       session[:selected_freeculture] = false
       existing_freeculture_constraint = session[:constraints].select { |constraint| constraint.is_a?(FreeCultureConstraint) } 
       existing_freeculture_constraint.each { |constraint| session[:constraints].delete constraint } if existing_freeculture_constraint.size > 0       
     end
     
     redirect_to :action => 'browse'
   end
   
   # constrains the search by the specified resources
   def constrain_resources
     
     # this is the list of things that are checked
     checked_facets = params[:constrain_resources] ? params[:constrain_resources].keys : []

     # we don't want to negatively constrain on items that are checked, so remove any such constraints
     checked_facets.each { |facet| 
       existing_facet_constraints = session[:constraints].select { |constraint| constraint.is_negative_facet_constraint?(facet) } 
       existing_facet_constraints.each { |constraint| session[:constraints].delete constraint }
     }

     # checkboxes don't give us a list of what is not checked, so we have to figure that out
     all_facets = FacetCategory.find( :all, :conditions => "type = 'FacetValue'").map { |facet| facet.value }
     unchecked_facets = all_facets - checked_facets
     
     # add a negative facet constraint for each unchecked item
     unchecked_facets.each { |facet|
       existing_facet_constraints = session[:constraints].select { |constraint| constraint.is_negative_facet_constraint?(facet) } 
       session[:constraints] << FacetConstraint.new( :field => 'archive', :value => facet, :inverted => true ) unless existing_facet_constraints.size > 0
     }
     
     # record which facets have been selected
     session[:selected_resource_facets] = checked_facets
     
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
    session[:selected_freeculture] = false
    session[:constraints] = []
   end
   
   def setup_ajax_calls(params)
     session[:items_per_page] ||= MIN_ITEMS_PER_PAGE
     user = session[:user] ? User.find_by_username(session[:user][:username]) : nil
     @page = params[:page_num].to_i
     @index = params[:row_num].to_i 
     @row_id = "search-result-#{@index}" 
     @results = search_solr(session[:constraints], @page, session[:items_per_page])
     @hit = @results['hits'][@index]
     return user
   end
   
   public
   def details
      setup_ajax_calls(params)

      render :partial => 'result_row', :locals => { :row_id => @row_id, :page => @page, :index => @index, :hit => @hit }
  end
   
   def collect
     # Only collect if the item isn't already collected and if there is a user logged in.
     # This would normally be the case, but there are strange effects if the user is logged in two browsers, or if the user's session was idle too long.
     user = setup_ajax_calls(params)
     CollectedItem.collect_item(user, @hit['uri']) unless user == nil

     # expire the fragment caches for the clouds related to this user
     #expire_timeout_fragment( %r{/cloud/#{session[:user][:username]}_user} )    

     render :partial => 'result_row', :locals => { :row_id => @row_id, :page => @page, :index => @index, :hit => @hit }
   end

   def uncollect
     user = setup_ajax_calls(params)
     CollectedItem.remove_collected_item(user, @hit['uri']) unless user == nil

     # expire the fragment caches for the clouds related to this user
     #expire_timeout_fragment( %r{/cloud/#{session[:user][:username]}_user} )    

     render :partial => 'result_row', :locals => { :row_id => @row_id, :page => @page, :index => @index, :hit => @hit }
   end
   
   def add_tag
     tag = params[:tag]
     user = setup_ajax_calls(params)
     CollectedItem.add_tag(user, @hit['uri'], tag) unless user == nil

     # expire the fragment caches for the clouds related to this user
     #expire_timeout_fragment( %r{/cloud/#{session[:user][:username]}_user} )    

     render :partial => 'result_row', :locals => { :row_id => @row_id, :page => @page, :index => @index, :hit => @hit }
   end
   
   def remove_tag
     tag = params[:tag]
     user = setup_ajax_calls(params)
     CollectedItem.delete_tag(user, @hit['uri'], tag) unless user == nil

     # expire the fragment caches for the clouds related to this user
     #expire_timeout_fragment( %r{/cloud/#{session[:user][:username]}_user} )    

     render :partial => 'result_row', :locals => { :row_id => @row_id, :page => @page, :index => @index, :hit => @hit }
   end
   
   def set_annotation
     note = params[:note]
     user = setup_ajax_calls(params)
     CollectedItem.set_annotation(user, @hit['uri'], note) unless user == nil

     # expire the fragment caches for the clouds related to this user
     #expire_timeout_fragment( %r{/cloud/#{session[:user][:username]}_user} )    

     render :partial => 'result_row', :locals => { :row_id => @row_id, :page => @page, :index => @index, :hit => @hit }
   end
   
   def auto_complete_for_search_keyword
     @field = 'content'
     @values = []
     if params['search']
       result = @solr.facet(@field, session[:constraints], params['search']['keyword'])
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
     results = @solr.search(session[:constraints], (page - 1) * items_per_page, items_per_page)        
     results
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
    constraints_with_ids.select { |constraint| 
      !constraint[:constraint].is_a?(FreeCultureConstraint) and
      (constraint[:constraint].is_a?(ExpressionConstraint) or 
      (constraint[:constraint].is_a?(FacetConstraint) and constraint[:constraint][:field] == 'genre') )
    }
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
