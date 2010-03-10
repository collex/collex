class ClassroomController < ApplicationController
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
		@forest = FacetCategory.sorted_facet_tree().sorted_children
		@results = { :total_hits => 0, :num_pages => 1, :hits => [ ] }
	end

end
