class CommunitiesController < ApplicationController
	layout 'nines'
	before_filter :init_view_options

	private
	def init_view_options
		@site_section = :shared
		session[:community_sort_by] ||= 'Title'
		session[:community_view_by] ||= 'Groups'
		session[:community_page_num] ||= 0
		session[:community_search_term] ||= nil
		return true
	end
	public

	def index
		@discussions = DiscussionTopic.get_most_popular(5)
		#@tags = CachedResource.get_most_popular_tags(40)
		@tags = CachedResource.get_most_recent_tags(40)
		@results = get_results()
	end

	def search
		term = params[:term]
		term = nil if term && term.length == 0
		session[:community_page_num] = 0
		session[:community_search_term] = term
		session[:community_sort_by] = 'Most Recent'
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
		options = { :facet => { :federation => DEFAULT_FEDERATION, :section => 'community' }, :user_id => get_curr_user_id(), :terms => session[:community_search_term], :page_size => 10, :page => session[:community_page_num] }
		case session[:community_view_by]
		when 'Groups' then
			options[:facet][:group] = true
			options[:facet][:cluster] = false
			options[:facet][:exhibit] = false
			options[:facet][:comment] = false
		when 'Clusters' then
			options[:facet][:group] = false
			options[:facet][:cluster] = true
			options[:facet][:exhibit] = false
			options[:facet][:comment] = false
		when 'Exhibits' then
			options[:facet][:group] = false
			options[:facet][:cluster] = false
			options[:facet][:exhibit] = true
			options[:facet][:comment] = false
		when 'Discussions' then
			options[:facet][:group] = false
			options[:facet][:cluster] = false
			options[:facet][:exhibit] = false
			options[:facet][:comment] = true
		when 'All' then
			options[:facet][:group] = true
			options[:facet][:cluster] = true
			options[:facet][:exhibit] = true
			options[:facet][:comment] = true
		end
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
