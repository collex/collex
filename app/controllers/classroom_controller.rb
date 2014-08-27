# encoding: UTF-8
class ClassroomController < ApplicationController
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
		if params[:id] == nil || params[:id] > "0"
			session[:classroom_group_facet] = params[:id]
		else
			session[:classroom_group_facet] = nil
		end
		make_facet_tree()
		render :partial => 'content', :locals => { :results => get_results(), :institutions => @institutions, :people => @people, :course_title => @course_title, :course_number => @course_number }
	end

	def index
		make_facet_tree()
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
			term = term.gsub(/[^ \p{Word}]/,' ').gsub(/\s+/, ' ').strip()
			#term = "\"#{term}\"" if term.include?(' ')
		end
		session[:classroom_page_num] = 0
		session[:classroom_search_term] = term
		session[:classroom_sort_by] = 'Most Recent'
		session[:classroom_view_by] = "All" if term != nil && term.length > 0
		render :partial => 'shared_objects', :locals => { :results => get_results() }
	end

	def sort_by
		session[:classroom_page_num] = 0
		session[:classroom_sort_by] = params[:sort] if params[:sort]
		render :partial => 'shared_objects', :locals => { :results => get_results() }
	end

	def view_by
		session[:classroom_page_num] = 0
		session[:classroom_view_by] = params[:view] if params[:view]
		render :partial => 'shared_objects', :locals => { :results => get_results() }
	end

	def page
		pg = params[:page]
		pg = pg.to_i if pg != nil
		session[:classroom_page_num] = pg - 1 if pg != nil && pg > 0
		render :partial => 'shared_objects', :locals => { :results => get_results() }
	end

	private
	def get_results()
		@searcher ||= SearchUserContent.new
		options = { :facet => { :federation => Setup.default_federation(), :section => 'classroom', :object_type => session[:classroom_view_by] }, :user_id => get_curr_user_id(), :terms => session[:classroom_search_term], :page_size => 10, :page => session[:classroom_page_num] }
		if session[:classroom_group_facet] != nil && session[:classroom_group_facet].to_i > 0
			options[:facet][:group_id] = session[:classroom_group_facet]
		end
		case session[:classroom_sort_by]
		when 'Relevancy' then options[:sort_by] = :relevancy
		when 'Title' then options[:sort_by] = :title_sort
		when 'Most Recent' then options[:sort_by] = :last_modified
		end
		results = @searcher.find_objects(options)
		# returns: { total_hits => int, num_pages => int, hits => [ ActiveRecord: Exhibit,Cluster,Group ] }
		return results
	end

	def make_facet_tree
		groups = Group.where({group_type: 'classroom'})
		@institutions = [ { :label => 'Universities', :children => {} }]
		@people = [ { :label => 'Faculty', :children => {} }]
		@course_title = [ { :label => 'Course Title', :children => {} }]
		@course_number = [ { :label => 'Course Number', :children => {} }]
		groups.each{|group|
			total = Exhibit.count(:all, :conditions => "group_id = #{group.id}")
			total += Cluster.count(:all, :conditions => "group_id = #{group.id}")
			total += DiscussionThread.count(:all, :conditions => "group_id = #{group.id}")
			total += 1	# for the group itself
			selected = session[:classroom_group_facet] == "#{group.id}"
			item_id = selected ? 0 : group.id
			item = { :id => item_id, :name => group.name, :count => total, :selected => selected }
			university = group.university
			if @institutions[0][:children][university]
				@institutions[0][:children][university].push(item)
			else
				@institutions[0][:children][university] = [ item ]
			end
			people = group.get_all_editors()
			people.each{|person|
				item = { :id => item_id, :name => group.name, :count => total, :selected => selected }
				name = User.find(person).fullname
				if @people[0][:children][name]
					@people[0][:children][name].push(item)
				else
					@people[0][:children][name] = [ item ]
				end
			}
			classname = group.course_name
			item = { :id => item_id, :name => group.name, :count => total, :selected => selected }
			if @course_title[0][:children][classname]
				@course_title[0][:children][classname].push(item)
			else
				@course_title[0][:children][classname] = [ item ]
			end
			item = { :id => item_id, :name => group.name, :count => total, :selected => selected }
			classnumber = group.course_mnemonic
			if @course_number[0][:children][classnumber]
				@course_number[0][:children][classnumber].push(item)
			else
				@course_number[0][:children][classnumber] = [ item ]
			end
		}
		# if there is only one item in the node, then don't have a node, just use the item as an end point
		for obj in @course_title[0][:children]
			if obj[1].length == 1
				@course_title[0][:children][obj[0]] = obj[1][0]
				obj[1][0][:name] = obj[0]
			end
		end
		for obj in @course_number[0][:children]
			if obj[1].length == 1
				@course_number[0][:children][obj[0]] = obj[1][0]
				obj[1][0][:name] = obj[0]
			end
		end
	end
end
