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
   layout 'collex'
   before_filter :authorize, :only => [:collect, :save, :remove_saved_search]
   
   def initialize
      @solr = CollexEngine.new(COLLEX_ENGINE_PARAMS)
   end
   
   def browse
     items_per_page = 4
     @page = params[:page] ? params[:page].to_i : 1
     
     
     # just cache the top level page.
     @fragment_key = '/browse/page1' unless session[:constraints].length > 0
     
     if is_cache_expired?(@fragment_key) 
       begin
         @results = search_solr(session[:constraints], @page, items_per_page)
       rescue  Net::HTTPServerException => e
         @results = {"facets" => {"archive" => {}}, "total_hits" => 0}
         error_message = e.message
         if (match = error_message.match( /Query_parsing_error_/ ))
       	   error_message = match.post_match
         else
           error_message = error_message.gsub(/^\d\d\d \"(.*)\"/,'\1')
         end
         flash[:error] = render_to_string(:inline => "Sorry! you've entered a search string with invalid characters.  You should <%=link_to 'clear all your constraints', :action => :clear_constraints%> or remove the offending search string below.")
       end

       @num_pages = @results["total_hits"].to_i.quo(items_per_page).ceil      
       @total_documents = @results["total_documents"]     
       @sites_forest = FacetCategory.find_by_value('archive').merge_facets(@results["facets"]['archive'])
     end

     render :action => 'results'
   end
   
   # allows queries to be linked in directly, or typed into the browser directly
   def search
     session[:constraints] = [ExpressionConstraint.new(:value => params[:q])]
     browse
   end
   
   def index
     home
   end
   
   def home
     browse
   end
   
   def add_facet
     if params[:field] and params[:value]
       session[:constraints] << FacetConstraint.new(:field => params[:field], :value => params[:value], :inverted => params[:invert] ? true : false)
     end
     redirect_to :action => 'browse'
   end

   def add_agent_facet
     if params['agent'] and params['agent']['name'] and not params['agent']['name'].strip.empty?
       session[:constraints] << FacetConstraint.new(:field => 'agent_facet', :value => params['agent']['name'], :inverted => params[:invert] ? true : false)
     end
     redirect_to :action => 'browse'
   end

   def add_year_facet
     if params['field'] and params['field']['year'] and not params['field']['year'].strip.empty?
       session[:constraints] << FacetConstraint.new(:field => 'year', :value => params['field']['year'], :inverted => params[:invert] ? true : false)
     end
     redirect_to :action => 'browse'
   end

   def remove_facet
      index = params[:index].to_i
      if index < session[:constraints].size
        session[:constraints].delete_at index
      end
      redirect_to :action => 'browse'
   end
   
   def invert_constraint
      index = params[:index].to_i
      if index < session[:constraints].size
        constraint = session[:constraints][index]
        constraint.inverted = !constraint.inverted
      end
      redirect_to :action => 'browse'
   end

   def new_expression
     session[:constraints] = []
     add_expression
   end
   
   def add_expression
     if params['field'] and params['field']['content']
       expression = params['field']['content']
       if expression and expression.strip.size > 0
         session[:constraints] << ExpressionConstraint.new(:value => expression)
       end
     end
     redirect_to :action => 'browse'
   end
   
   def add_freeculture_facet
     session[:constraints] << FreeCultureConstraint.new(:inverted => params[:invert] ? false : true)
     redirect_to :action => 'browse'
   end
   
   def clear_constraints
      session[:constraints] = []
      redirect_to :action => 'browse'      
   end
   
   def collect
     user = User.find_by_username(session[:user][:username])

     # expire the fragment caches for the clouds related to this user
     expire_timeout_fragment( %r{/cloud/#{session[:user][:username]}_user} )    
     
     uris = params[:objid].split(' ~~ ')  # TODO make this a constant shared by the results.rhtml code that joins uris together
     cached_documents = CachedResource.resources_by_uri(uris)
     
     cached_documents.each do |cached_document|
       interpretation = user.interpretations.find_by_object_uri(cached_document.uri)
       interpretation = user.interpretations.build(:object_uri => cached_document.uri) if interpretation.nil?
       interpretation.annotation = params[:annotation]
       interpretation.tag_list = params[:tags]
       interpretation.save!
       interpretation.tags.each do |tag| 
        cached_document.tags << tag
       end
       cached_document.save!
     end
     
     if request.xhr?
       render :text =>  "collected"
     else
       # TODO: set the "sidebar" state to the object detail
       redirect_to :controller => 'search', :action => 'browse'
     end
   end
   
   def auto_complete_for_field_content
     # TODO
     @field = 'content'
     @values = []
     if params['field']
       result = @solr.facet(@field, session[:constraints], params['field']['content'])
       @values = result.sort {|a,b| b[1] <=> a[1]}
     end
     
     render :partial => 'suggest'
   end

   def auto_complete_for_field_year
     # TODO
     @field = 'year'
     @values = []
     if params['field']
       result = @solr.facet(@field, session[:constraints], params['field']['year'])
       @values = result.sort {|a,b| b[1] <=> a[1]}
     end
     
     render :partial => 'suggest'
   end
   
   def auto_complete_for_agent_name
     # TODO
     @values = []
     if params['agent']
       @values = @solr.agent_suggest(session[:constraints], params['agent']['name'])
     end

     render :partial => 'agents'
   end   
   
   def suggest
     render :layout => 'bare'
   end
   
   def save
     user = User.find_by_username(session[:user][:username])
     search = user.searches.find_or_create_by_name(params[:name])

     # [{:value=>"rossetti", :invert=>false, :field=>"archive"}, {:invert=>true, :expression=>"damsel"}]
     
     search.constraints.clear
     session[:constraints].each do |c|
       case c
       when SavedSearchConstraint
         saved_search = User.find_by_username(c.field).searches.find_by_name(c.value)
         saved_search.constraints.each do |saved_constraint|
           search.constraints << saved_constraint.clone
         end
       else
         search.constraints << c
       end
     end
     search.save!
     
     redirect_to :action => 'browse'
   end
   
   def add_saved_search
     # TODO: check for validity of saved search
     session[:constraints] << SavedSearchConstraint.new(:field => params[:username], :value => params[:name], :inverted => params[:invert] ? true : false)
     redirect_to :action => 'browse'
   end
   
   def saved_permalink
     user = User.find_by_username(params[:username])
     saved_search = user.searches.find_by_name(params[:name]) unless user.nil?
     
     if saved_search
       session[:constraints] = []
       saved_search.constraints.each do |saved_constraint|
         session[:constraints] << saved_constraint
       end
     else
       flash[:error] = 'Saved search not found.'
     end
     browse
   end
   
   def remove_saved_search
     user = User.find_by_username(session[:user][:username])
     search = user.searches.find(params[:id])

     session[:constraints].delete_if {|item| item.is_a?(SavedSearchConstraint) && item.field == session[:user][:username] && item.value == search.name }
     
     search.destroy
     
     redirect_to :action => 'browse'
   end
   
   def edit_saved_search
     session[:constraints] = []
     saved_search = User.find_by_username(session[:user][:username]).searches.find(params[:id])
     saved_search.constraints.each do |saved_constraint|
       session[:constraints] << saved_constraint
     end
     redirect_to :action => 'browse'      
   end

   private
   def search_solr(constraints, page, items_per_page)
     results = @solr.search(session[:constraints], (page - 1) * items_per_page, items_per_page)        
     results
   end
  
end
