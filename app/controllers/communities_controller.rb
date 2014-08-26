# encoding: UTF-8
class CommunitiesController < ApplicationController
	before_filter :init_view_options

	private
	def init_view_options
		@site_section = :shared
		session[:community_sort_by] ||= 'Title'
		session[:community_view_by] ||= Setup.community_default_search()
		session[:community_page_num] ||= 0
		session[:community_search_term] ||= nil
		return true
	end
	public

	def index
		@discussions = DiscussionTopic.get_most_popular(5)
		#@tags = CachedResource.get_most_popular_tags(40)
		@tags = CachedResource.get_most_recent_tags(40)
		session[:community_page_num] ||= 0
		session[:community_sort_by] ||= 'Most Recent'
		session[:community_view_by] ||= "All"
		begin
			@results = get_results()
		rescue Catalog::Error => e
			flash[:error] = e.to_s
			@message = e.to_s
			@results = { total_hits: 0, total: 0, num_pages: 1, hits: [] }
		end
	end

	def search
		term = params[:term]
		term = nil if term && term.length == 0
		if term
			term = term.gsub("’", "'").gsub(/[^ \p{Word}']/,' ').gsub(/\s+/, ' ').strip()
			#term = "\"#{term}\"" if term.include?(' ')
		end
		session[:community_page_num] = 0
		session[:community_search_term] = term
		session[:community_sort_by] = 'Most Recent'
		session[:community_view_by] = "All" if term != nil && term.length > 0
		render :partial => 'shared_objects', :locals => { :results => get_results() }
	end

	def sort_by
		session[:community_page_num] = 0
		session[:community_sort_by] = params[:sort] if params[:sort]
		render :partial => 'shared_objects', :locals => { :results => get_results() }
	end

	def view_by
		session[:community_page_num] = 0
		session[:community_view_by] = params[:view] if params[:view]
		render :partial => 'shared_objects', :locals => { :results => get_results() }
	end

	def page
		pg = params[:page]
		pg = pg.to_i if pg != nil
		session[:community_page_num] = pg - 1 if pg != nil && pg > 0
		render :partial => 'shared_objects', :locals => { :results => get_results() }
	end

	private
	def get_results()
		@searcher ||= SearchUserContent.new
		options = { :facet => { :federation => Setup.default_federation(), :section => 'community', :object_type => session[:community_view_by] }, :user_id => get_curr_user_id(), :terms => session[:community_search_term], :page_size => 10, :page => session[:community_page_num] }
		case session[:community_sort_by]
		when 'Relevancy' then options[:sort_by] = :relevancy
		when 'Title' then options[:sort_by] = :title_sort
		when 'Most Recent' then options[:sort_by] = :last_modified
		end
		results = @searcher.find_objects(options)
		# returns: { total_hits => int, num_pages => int, hits => [ ActiveRecord: Exhibit,Cluster,Group ] }
		return results
	end
end
