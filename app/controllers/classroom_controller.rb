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

	def facet_on_group
		@facetted_group_id = params[:id]
		redirect_to :action => 'index'
	end

	def index
		groups = Group.find_all_by_group_type('classroom')
		@institutions = [ { :label => 'UNIVERSITIES', :children => {} }]
		@people = [ { :label => 'FACULTY', :children => {} }]
		@classes = [ { :label => 'CLASSES', :children => {} }]
		groups.each{|group|
			university = group.university
			if @institutions[0][:children][university]
				@institutions[0][:children][university].push(group)
			else
				@institutions[0][:children][university] = [ group ]
			end
			people = group.get_all_editors()
			people.each{|person|
				name = User.find(person).fullname
				if @people[0][:children][name]
					@people[0][:children][name].push(group)
				else
					@people[0][:children][name] = [ group ]
				end
			}
			classname = group.name
			if @classes[0][:children][classname]
				@classes[0][:children][classname].push(group)
			else
				@classes[0][:children][classname] = [ group ]
			end
		}
		@results = { :total_hits => 0, :num_pages => 1, :hits => [ ] }
	end

end
