class SearchController < ApplicationController
   layout 'nines', :except => ['years']
   before_filter :authorize, :only => [:collect, :save, :remove_saved_search]
   
   def initialize
      @solr = CollexEngine.new
   end
   
   def browse
     items_per_page = 20
     @page = params[:page] ? params[:page].to_i : 1
     
     @results = search(session[:constraints], @page, items_per_page)

     @num_pages = @results["total_hits"].to_i.quo(items_per_page).ceil      
     @total_documents = @results["total_documents"]
     
     # initially all unccategorized.  #to_facet_tree removes ones found in the category mappings
     uncategorized_sites = @results['facets']['archive'].clone  
     @sites_forest = FacetCategory.find_by_value('archive').merge_facets(@results["facets"]['archive'], uncategorized_sites)
     
     # Merge uncategorized facets under an "Uncategorized" child
     uncategorized_tree = {:value => "Uncategorized", :children => [], :count => 0, :type => :category}
     uncategorized_sites.each do |k,v|
       uncategorized_tree[:children] << {:value => k, :children => [], :count => v, :type => :value}
       uncategorized_tree[:count] += v
     end
     @sites_forest << uncategorized_tree
     
     render :action => 'results'
   end
   
   def index
     home
   end
   
   def home
     browse
   end
   
   def add_facet
     if params[:field] and params[:value]
       session[:constraints] << {:type => :facet, :field => params[:field], :value => params[:value], :invert => params[:invert] ? true : false}
     end
     redirect_to :action => 'browse'
   end

   def add_agent_facet
     if params['agent'] and params['agent']['name'] and not params['agent']['name'].strip.empty?
       session[:constraints] << {:type => :facet, :field => "agent", :value => params['agent']['name'], :invert => params[:invert] ? true : false}
     end
     redirect_to :action => 'browse'
   end

   def add_year_facet
     if params['field'] and params['field']['year'] and not params['field']['year'].strip.empty?
       session[:constraints] << {:type => :facet, :field => "year", :value => params['field']['year'], :invert => params[:invert] ? true : false}
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
        session[:constraints][index][:invert] = !session[:constraints][index][:invert]
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
         logger.debug("------expression: #{expression}")
         session[:constraints] << {:type => :expression, :expression => expression}
         logger.debug("------constraints: #{session[:constraints].last[:expression]}")
       end
     end
     redirect_to :action => 'browse'
   end
   
   def clear_constraints
      session[:constraints] = []
      redirect_to :action => 'browse'      
   end
   
   def collect
     user = User.find_by_username(session[:user][:username])
     
     uris = params[:objid].split(' ~~ ')  # TODO make this a constant shared by the results.rhtml code that joins uris together
     
     uris.each do |uri|
       interpretation = user.interpretations.find_by_object_uri(uri)
       if not interpretation
         interpretation = Interpretation.new(:object_uri => uri)
         user.interpretations << interpretation
       end
       interpretation.annotation =  params[:annotation]
       interpretation.tag_list = params[:tags]
       interpretation.save!
     end
     
     if request.xhr?
       render_text "collected"
     else
       # TODO: set the "sidebar" state to the object detail
       redirect_to :controller => 'search', :action => 'browse'
     end
   end
   
   def years
     # TODO fix for Ruby object results, not XML
     @results = @solr.facet('year',session[:constraints])
     dom = @results[:dom]

     list = dom.elements.to_a( "/response/lst/long" )
     values = []
     @unspecified = 0
     list.each do |item|
       year = item.attributes["name"]
       if year != "<unspecified>"
         if year == "0012"
           year = "1881"
         end
         values << [year.to_i, item.text.to_i]
       else
         @unspecified = item.text
       end
     end
     values.sort! {|a,b| a[0] <=> b[0]}
     @buckets = Array.new(120) { 0 }
     
     min_year = values.first()[0].to_i
     max_year = values.last()[0].to_i
     years_per_bucket = (max_year - min_year).quo(120).ceil
     logger.debug "#{min_year} - #{max_year} : #{years_per_bucket}"
     values.each do |value|
       bucket_index = (value[0].to_i - min_year).quo(years_per_bucket).floor
       logger.debug "#{value[1]} : #{bucket_index}"
       @buckets[bucket_index] += value[1]
     end
     
     logger.debug "unspecified: #{@unspecified}"
   end
   
   def auto_complete_for_field_content
     @field = 'content'
     @values = []
     if params['field']
       result = @solr.facet(@field, session[:constraints], @field, params['field']['content'])
       @values = result.sort {|a,b| b[1] <=> a[1]}
     end
     
     render :partial => 'suggest'
   end

   def auto_complete_for_field_year
     @field = 'year'
     @values = []
     if params['field']
       result = @solr.facet(@field, session[:constraints], @field, params['field']['year'])
       @values = result.sort {|a,b| b[1] <=> a[1]}
     end
     
     render :partial => 'suggest'
   end
   
   def auto_complete_for_agent_name
     @values = []
     if params['agent']
       results = @solr.facet('agent', session[:constraints], 'agent', params['agent']['name'])
       results.each do |agent, roles_data|
         total = 0
         roles = {}
         roles_data.each do |name, freq|
           roles[name[-3,3]] = freq
           total += freq
         end
         if total > 0
           @values << {:name => agent, :roles => roles, :total => total}
         end
        end
        @values.sort! {|a,b| b[:total] <=> a[:total]}
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
       case c[:type]
       when :expression
         # TODO: The ExpressionConstraint model should be enhanced to have a #expression property on it so the "hack" is transparent
         search.constraints << ExpressionConstraint.create(:value => c[:expression], :inverted => c[:invert])
       when :facet
         search.constraints << FacetConstraint.create(:field => c[:field], :value => c[:value], :inverted => c[:invert])
       when :saved
         saved_search = User.find_by_username(c[:field]).searches.find_by_name(c[:value])
         saved_search.constraints.each do |saved_constraint|
           search.constraints << saved_constraint.clone
         end
       end
     end
     search.save!
     
     redirect_to :action => 'browse'
   end
   
   def add_saved_search
     # TODO: check for validity of saved search
     session[:constraints] << {:type => :saved, :field => params[:username], :value => params[:name], :invert => params[:invert] ? true : false}
     redirect_to :action => 'browse'
   end
   
   def saved_permalink
     saved_search = User.find_by_username(params[:username]).searches.find_by_name(params[:name])
     
     if saved_search
       session[:constraints] = []
       saved_search.constraints.each do |saved_constraint|
         session[:constraints] << saved_constraint.to_hash
       end
     else
       flash[:error] = 'Saved search not found.'
     end
     browse
   end
   
   def remove_saved_search
     user = User.find_by_username(session[:user][:username])
     search = user.searches.find(params[:id])

     session[:constraints].delete_if {|item| item[:type] == :saved && item[:field] == session[:user][:username] && item[:value] == search.name }
     
     search.destroy
     
     redirect_to :action => 'browse'
   end
   
   def edit_saved_search
     session[:constraints] = []
     saved_search = User.find_by_username(session[:user][:username]).searches.find(params[:id])
     saved_search.constraints.each do |saved_constraint|
       session[:constraints] << saved_constraint.to_hash
     end
     redirect_to :action => 'browse'      
   end

   private
   def search(constraints, page, items_per_page)
     results = @solr.search(session[:constraints], (page - 1) * items_per_page, items_per_page)   
     
     results
   end
   
   def merge_categories_with_facets(categories, facets) # facets: {'rossetti' => 10}
   end
end
