class TestJsController < ApplicationController
	before_filter :init_view_options

	private
	def init_view_options
		@site_section = :home
		return true
	end
	public

	def general_dialog
	end

end
