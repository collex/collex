class PublicationsController < ApplicationController
	layout 'nines'
	before_filter :init_view_options

	private
	def init_view_options
		@site_section = :shared
		return true
	end
	public

	def index
		@publications = Group.find_all_by_group_type('peer-reviewed')
	end

end
