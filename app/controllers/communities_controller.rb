class CommunitiesController < ApplicationController
	layout 'nines'
	before_filter :init_view_options

	private
	def init_view_options
		@site_section = :shared
		return true
	end
	public

	def index
		session[:community_sort_by] ||= 'Title'
		session[:community_view_by] ||= 'Groups'
		session[:community_page_num] ||= 0
		session[:community_search_term] ||= nil
		@discussions = DiscussionTopic.get_most_popular(5)
		@tags = CachedResource.get_most_popular_tags(40)
		@results = get_results()
	end

	def search
		term = params[:term]
		term = nil if term.length == 0
		session[:community_page_num] = 0
		session[:community_search_term] = term
		session[:community_sort_by] = 'Most Recent'
		render :partial => 'shared_objects', :locals => { :results => get_results() }
	end

	def sort_by
		session[:community_page_num] = 0
		session[:community_sort_by] = params[:sort]
		render :partial => 'shared_objects', :locals => { :results => get_results() }
	end

	def view_by
		session[:community_page_num] = 0
		session[:community_view_by] = params[:view]
		render :partial => 'shared_objects', :locals => { :results => get_results() }
	end

	def page
		session[:community_page_num] = params[:page].to_i - 1
		render :partial => 'shared_objects', :locals => { :results => get_results() }
	end

	private
	def get_results()
		@searcher ||= SearchUserContent.new
		options = { :facet => { :federation => SITE_NAME, :section => 'community' }, :user_id => get_curr_user_id(), :terms => session[:community_search_term], :page_size => 10, :page => session[:community_page_num] }
		case session[:community_view_by]
		when 'Groups' then
			options[:facet][:group] = true
			options[:facet][:cluster] = false
			options[:facet][:exhibit] = false
		when 'Clusters' then
			options[:facet][:group] = false
			options[:facet][:cluster] = true
			options[:facet][:exhibit] = false
		when 'Exhibits' then
			options[:facet][:group] = false
			options[:facet][:cluster] = false
			options[:facet][:exhibit] = true
		when 'All' then
			options[:facet][:group] = true
			options[:facet][:cluster] = true
			options[:facet][:exhibit] = true
		end
		case session[:community_sort_by]
		when 'Relevancy' then options[:sort_by] = :relevancy
		when 'Title' then options[:sort_by] = :title
		when 'Most Recent' then options[:sort_by] = :most_recent
		end
		results = @searcher.find_objects(options)
		# returns: { total_hits => int, num_pages => int, hits => [ ActiveRecord: Exhibit,Cluster,Group ] }
		return results
	end
end
