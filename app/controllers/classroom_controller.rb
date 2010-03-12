class ClassroomController < ApplicationController
	layout 'nines'
	before_filter :init_view_options

	private
	def init_view_options
		@site_section = :shared
		session[:classroom_sort_by] ||= 'Title'
		session[:classroom_view_by] ||= 'Groups'
		session[:classroom_page_num] ||= 0
		session[:classroom_search_term] ||= nil
		session[:classroom_group_facet] ||= nil
		return true
	end
	public

	def facet_on_group
		session[:classroom_group_facet] = params[:id]
		render :partial => 'shared_objects', :locals => { :results => get_results() }
	end

	def index
		groups = Group.find_all_by_group_type('classroom')
		@institutions = [ { :label => 'Universities', :children => {} }]
		@people = [ { :label => 'Faculty', :children => {} }]
		@course_title = [ { :label => 'Course Title', :children => {} }]
		@course_number = [ { :label => 'Course Number', :children => {} }]
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
			classname = group.course_name
			if @course_title[0][:children][classname]
				@course_title[0][:children][classname].push(group)
			else
				@course_title[0][:children][classname] = [ group ]
			end
			classnumber = group.course_mnemonic
			if @course_number[0][:children][classnumber]
				@course_number[0][:children][classnumber].push(group)
			else
				@course_number[0][:children][classnumber] = [ group ]
			end
		}
		# if there is only one item in the node, then don't have a node, just use the item as an end point
		for obj in @course_title[0][:children]
			if obj[1].length == 1
				@course_title[0][:children][obj[0]] = obj[1][0]
				obj[1][0].name = obj[0]
			end
		end
		for obj in @course_number[0][:children]
			if obj[1].length == 1
				@course_number[0][:children][obj[0]] = obj[1][0]
				obj[1][0].name = obj[0]
			end
		end
		@results = get_results()
	end

	def search
		term = params[:term]
		term = nil if term.length == 0
		session[:classroom_page_num] = 0
		session[:classroom_search_term] = term
		session[:classroom_sort_by] = 'Most Recent'
		render :partial => 'shared_objects', :locals => { :results => get_results() }
	end

	def sort_by
		session[:classroom_page_num] = 0
		session[:classroom_sort_by] = params[:sort]
		render :partial => 'shared_objects', :locals => { :results => get_results() }
	end

	def view_by
		session[:classroom_page_num] = 0
		session[:classroom_view_by] = params[:view]
		render :partial => 'shared_objects', :locals => { :results => get_results() }
	end

	def page
		session[:classroom_page_num] = params[:page].to_i - 1
		render :partial => 'shared_objects', :locals => { :results => get_results() }
	end

	private
	def get_results()
		@searcher ||= SearchUserContent.new
		options = { :facet => { :federation => SITE_NAME, :section => 'classroom' }, :user_id => get_curr_user_id(), :terms => session[:classroom_search_term], :page_size => 10, :page => session[:classroom_page_num] }
		case session[:classroom_view_by]
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
		case session[:classroom_sort_by]
		when 'Relevancy' then options[:sort_by] = :relevancy
		when 'Title' then options[:sort_by] = :title_sort
		when 'Most Recent' then options[:sort_by] = :most_recent
		end
		results = @searcher.find_objects(options)
		# returns: { total_hits => int, num_pages => int, hits => [ ActiveRecord: Exhibit,Cluster,Group ] }
		return results
	end
end
