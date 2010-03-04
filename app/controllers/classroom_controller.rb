class ClassroomController < ApplicationController
	layout 'nines'
	before_filter :init_view_options

	private
	def init_view_options
		@site_section = :shared
		return true
	end
	public

	def index
		@forest = FacetCategory.sorted_facet_tree().sorted_children
		@results = { :total_hits => 7, :num_pages => 1, :hits => [ ] }
	end

end
