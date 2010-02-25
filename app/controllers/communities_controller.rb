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
		session[:shared_sort_by] ||= 'Title'
		session[:shared_view_by] ||= 'Groups'
		@discussions = DiscussionTopic.get_most_popular(5)
		@tags = CachedResource.get_most_popular_tags(40)
		@results = get_results()
	end

	def search
		term = params[:term]
		term = nil if term.length == 0
		session[:community_search_term] = term
		# TODO-PER: Actually do search here
		redirect_to :action => 'index'
	end

	def sort_by
		session[:shared_sort_by] = params[:sort]
		render :partial => 'objects', :locals => { :results => get_results() }
	end

	def view_by
		session[:shared_view_by] = params[:view]
		render :partial => 'objects', :locals => { :results => get_results() }
	end

	private
	def get_results()
		case session[:shared_view_by]
		when 'Groups' then results = Group.all
		when 'Clusters' then results = Cluster.all
		when 'Exhibits' then results = Exhibit.all
		when 'All' then results = Group.all + Cluster.all + Exhibit.all
		else results = []
		end
		return results
	end
end
