##########################################################################
# Copyright 2009 Applied Research in Patacriticism and the University of Virginia
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################

class ForumController < ApplicationController
  before_filter :init_view_options

   # Number of search results to display by default
   MIN_ITEMS_PER_PAGE = 10
   MAX_ITEMS_PER_PAGE = 30

    private
  def init_view_options
    @site_section = :discuss
    return true
  end
  public

	def object	# called from RSS
		id = params[:comment]
		if id != nil
			comment = DiscussionComment.find_by_id(id)
			if comment != nil
				redirect_to :controller => 'forum', :action => 'view_thread', :thread => comment.discussion_thread_id
			else
				render :text => "Bad Request", :status => :bad_request
			end
		else
			render :text => "Bad Request", :status => :bad_request
		end
	end

  def post_comment_to_new_thread
    if !user_signed_in?
      render :text => 'You must be signed in to start a discussion.', :status => :bad_request
    else
			params[:title] = params[:title].strip()
			params[:reply] = params[:reply].strip()
			err_msg = has_title(params)
			err_msg = has_body(params) if err_msg == nil

			if err_msg
				render :text => err_msg, :status => :bad_request
			else
				rec = { :title => params[:title], :license => params[:license_list], :discussion_topic_id => params[:topic_id] }
				rec[:group_id] = params[:group_id] if params[:group_id] && params[:group_id].to_i > 0
				rec[:cluster_id] = params[:cluster_id] if params[:cluster_id] && params[:cluster_id].to_i > 0
				thread = DiscussionThread.create(rec)

				params[:thread_id] = thread.id
				create_comment(params, :new)

		    redirect_to :action => :index
			end
    end
  end
  
  def post_comment_to_existing_thread
    if !user_signed_in?
      render :text => 'You must be signed in to reply to a thread.', :status => :bad_request
    else
			params[:reply] = params[:reply].strip()
			err_msg = has_body(params)
			if err_msg
				render :text => err_msg, :status => :bad_request
			else
				create_comment(params, :existing)
				retrieve_thread({ :thread => params[:thread_id], :page => '-1' })
				if @thread
					render :partial => 'replies', :locals => { :total => @total, :page => @page, :replies => @replies, :num_pages => @num_pages, :thread => @thread }
				else
					render :text => 'Sorry! This thread no longer exists.', :status => :bad_request
				end
			end
    end
  end

  def edit_existing_comment
    comment_id = params[:comment_id]
    inet_thumbnail = params[:inet_thumbnail]
    inet_url = params[:inet_url]
    inet_title = params[:inet_title]
    nines_object = params[:nines_obj_list]
    nines_exhibit = params[:exhibit_list]
    description = params[:reply]
    disc_type = params[:obj_type]
    title = params[:title]
    license = params[:license_list]
    can_delete = params[:can_delete] == 'true'
    
    comment = DiscussionComment.find(comment_id)
    # If an attachment was not selected, but the type expected an attachment, just change the type to regular comment
    if disc_type == 'mycollection' && nines_object.length == 0
      disc_type = ''
    elsif disc_type == 'exhibit' && nines_exhibit.length == 0
      disc_type = ''
    end
 
    if disc_type == ''
      comment.update_attributes(:comment_type => 'comment', :comment => description, :user_modified_at => Time.now)
    elsif disc_type == 'mycollection'
      cr = CachedResource.find_by_uri(nines_object)
      if cr == nil  # if the object hadn't been collected, let's just go ahead an collect it
        cr = CollectedItem.collect_item(user, nines_object, nil)
      end
      comment.update_attributes(:comment_type => 'nines_object', :cached_resource_id => cr.id, :comment => description, :user_modified_at => Time.now)
    elsif disc_type == 'exhibit'
      a = nines_exhibit.split('_')
      exhibit = Exhibit.find(a[1])
      comment.update_attributes(:comment_type => 'nines_exhibit', :exhibit_id => exhibit.id, :comment => description, :user_modified_at => Time.now)
    elsif disc_type == 'weblink'
      comment.update_attributes(:comment_type => 'inet_object', :link_title => inet_title, :link_url => inet_url, :image_url => inet_thumbnail, :comment => description, :user_modified_at => Time.now)
    end
    
    if comment.position == 1
      thread = DiscussionThread.find(comment.discussion_thread_id)
      thread.update_attributes(:license => license.to_i)
      thread.update_attributes(:title => title) if title.length > 0
    end
    
    render :partial => 'comment', :locals => { :comment => comment, :thread_id => comment.discussion_thread_id, :can_delete => can_delete, :can_edit => true, :is_main => comment.position == 1 }
  end
  
  private
	def has_title(params) # returns nil if ok, otherwise returns an error message
		return nil if params[:title].length > 0
    disc_type = params[:obj_type]
    if disc_type == 'mycollection' && params[:nines_obj_list].length == 0
      disc_type = ''
    elsif disc_type == 'exhibit' && params[:exhibit_list].length == 0
      disc_type = ''
    end
		return "Please enter a title or select an object to post a comment." if disc_type.length == 0

		return nil
	end

	def has_body(params)
    disc_type = params[:obj_type]
    if disc_type == 'mycollection' && params[:nines_obj_list].length == 0
      disc_type = ''
    elsif disc_type == 'exhibit' && params[:exhibit_list].length == 0
      disc_type = ''
    end

		return "Please enter a comment." if disc_type == '' && params[:reply].length == 0
		return nil
	end

  def create_comment(params, typ)
    thread_id = params[:thread_id]
    inet_thumbnail = params[:inet_thumbnail]
    inet_url = params[:inet_url]
    inet_title = params[:inet_title]
    nines_object = params[:nines_obj_list]
    nines_exhibit = params[:exhibit_list]
    description = params[:reply]
    disc_type = params[:obj_type]
    thread = DiscussionThread.find(thread_id)
    
    # If an attachment was not selected, but the type expected an attachment, just change the type to regular comment
    if disc_type == 'mycollection' && nines_object.length == 0
      disc_type = ''
    elsif disc_type == 'exhibit' && nines_exhibit.length == 0
      disc_type = ''
    end
 
    if disc_type == ''
      DiscussionComment.create(:discussion_thread_id => thread_id, :user_id => get_curr_user_id, :position => thread.discussion_comments.length+1, :comment_type => 'comment', :comment => description)
    elsif disc_type == 'mycollection'
      cr = CachedResource.find_by_uri(nines_object)
	  # If the object for some reason isn't in the cache (and there's no reason why not), then we will skip it. This would only happen if there were an inconsistency in the database somewhere.
	  if cr.blank?
		cr_id = nil
		  comment_type = 'comment'
		else
			cr_id = cr.id
		    comment_type = 'nines_object'
	  end
	  
      DiscussionComment.create(:discussion_thread_id => thread.id, :user_id => get_curr_user_id, :position => thread.discussion_comments.length+1,
        :comment_type => comment_type, :cached_resource_id => cr_id, :comment => description)
    elsif disc_type == 'exhibit'
      a = nines_exhibit.split('_')
      exhibit = Exhibit.find(a[1])
      DiscussionComment.create(:discussion_thread_id => thread.id, :user_id => get_curr_user_id, :position => thread.discussion_comments.length+1,
        :comment_type => 'nines_exhibit', :exhibit_id => exhibit.id, :comment => description)
    elsif disc_type == 'weblink'
      DiscussionComment.create(:discussion_thread_id => thread.id, :user_id => get_curr_user_id, :position => thread.discussion_comments.length+1,
        :comment_type => 'inet_object', :link_title => inet_title, :link_url => inet_url, :image_url => inet_thumbnail, :comment => description)
    end
		DiscussionVisit.visited(thread, current_user)
		send_notification(thread.id, thread.group_id, thread.get_title(), get_curr_user_name, typ)
  end

	def send_notification(thread_id, group_id, title, username, typ)
		return if group_id == nil || group_id.to_i <= 0
		group = Group.find_by_id(group_id)
		return if group == nil
		verb = typ == :new ? "started" : "replied to"
		verb2 = typ == :new ? "New" : "Reply to"
		GroupsUser.email_hook("discussion", group_id, "#{verb2} Forum Post \"#{title}\" in the group #{group.name}.",
			"#{username} has #{verb} the thread \"#{title}\" in the group #{group.name}.\n\nTo read the full thread, click here: #{url_for(:controller => 'forum', :action => 'view_thread', :thread => thread_id, :only_path => false)}",
			url_for(:controller => 'home', :action => 'index', :only_path => false))
  end
  
  public
  def post_object_to_new_thread
    if !user_signed_in? || params[:topic_id] == nil || request.request_method != 'POST'
      flash[:error] = 'You must be signed in to start a discussion.'
	  redirect_to :back
    else
      # There are two records that must be updated to create the new thread. If the second record
      # isn't created, then we need to back off the first one.
      topic_id = params[:topic_id]
	  topic_id = DiscussionTopic.first().id if params[:topic_id] == nil || params[:topic_id].to_i <= 0
	    license = params[:license_list]
			rec = { :title => params[:title], :license => license, :discussion_topic_id => topic_id }
			rec[:group_id] = params[:group_id] if params[:group_id] && params[:group_id].to_i > 0
			rec[:cluster_id] = params[:cluster_id] if params[:cluster_id] && params[:cluster_id].to_i > 0
      thread = DiscussionThread.create(rec)

      begin
        post_object(thread, params, :new)
      rescue
        thread.destroy() if thread
        flash[:error] = "We're sorry. An error occurred when attempting to start the discussion thread."
      end

		# now tell the caller where the post landed so they can go there.
		session[:items_per_page] ||= MIN_ITEMS_PER_PAGE
		threads = DiscussionTopic.find(topic_id).discussion_threads
		#num_pages = threads.length.quo(session[:items_per_page]).ceil
		render :text => "/forum/view_topic?page=1&topic=#{topic_id}"
    end
  end
  
  def get_exhibit_list
    # This is called through ajax and wants a json object back.
    exhibits = Exhibit.get_all_published()
    ret = []
    exhibits.each { |exhibit|
      obj = {}
      obj[:id] = "id_#{exhibit.id}"
      obj[:img] = exhibit.thumbnail
      obj[:img] = view_context.image_path(DEFAULT_THUMBNAIL_IMAGE_PATH) if obj[:img] == "" || obj[:img] == nil
      obj[:title] = exhibit.title
      obj[:strFirstLine] = exhibit.title
      obj[:strSecondLine] = ""
      ret.push(obj)
    }
    render :text => ret.to_json()
  end
  
  def get_object_details
		if params[:uri]
			hit = CachedResource.get_hit_from_uri(params[:uri])
			render :partial => '/results/result_row_for_popup', :locals => { :hit => hit, :extra_button_data => { :partial => params[:partial], :index => params[:index], :target_el  => params[:target_el]} }
		else
			render :text => 'We\'re sorry! We can\'t find the object that you requested. Reason: internal error (incorrect parameters). Please contact the #{Setup.site_name()} webmaster using the email at the bottom of the page', :status => :bad_request
		end
  end

	def get_nines_obj_list
		# This returns a json object with an array of hits.
		# The hits might be all the objects that have been collected by the current user, or
		# all the objects that are in a particular exhibit.
		# If illustration_id is passed, then the exhibit_id is figured out from it.
		# If exhibit_id is passed, then that is used to limit the objects to only those in the exhibit.
		# If is is not passed, then all of the user's collected objects are returned.
		# Except, if only_images is passed, then items without a thumbnail are skipped.
		only_images = params[:only_images]
		ret = []
		if user_signed_in?
			# if an element id is passed, then only the objects that are in that exhibit are returned.
			illustration_id = params[:illustration_id]
			if illustration_id
				illustration = ExhibitIllustration.find_by_id(illustration_id)
				if illustration
					element_id = illustration.exhibit_element_id
				end
			else
				element_id = params[:element_id]
			end
			if element_id
				element = ExhibitElement.find_by_id(element_id)
				if element
					page = ExhibitPage.find(element.exhibit_page_id)
					exhibit_id = page.exhibit_id
				end
			else
				exhibit_id = params[:exhibit_id]
			end
			
			if exhibit_id
				exhibits_objects = ExhibitObject.where({exhibit_id: exhibit_id})
				# TODO-PER: There is probably a cleaner way to do this, just convert a list of URI to cached_resource_id
				#objs = []
				exhibits_objects.each { |eo|
					cr = CachedResource.find_by_uri(eo[:uri])
#					o = CollectedItem.new
#					o.cached_resource_id = cr.id
#					objs.push(o)
#					objs.each {|obj|
						hit = CachedResource.get_hit_from_resource_id(cr.id)
						if hit != nil
							image = CachedResource.get_thumbnail_from_hit(hit)
							if only_images != true
								image = view_context.image_path(DEFAULT_THUMBNAIL_IMAGE_PATH) if image == "" || image == nil
							end
							if image && image.length > 0
								obj = {}
								obj[:id] = hit['uri']
								obj[:img] = image
								obj[:title] = hit['title']
								obj[:strFirstLine] = hit['title']
								obj[:strSecondLine] = hit['role_AUT'] ? hit['role_AUT'].join(', ') : hit['role_ART'] ? hit['role_ART'].join(', ') : ''
								ret.push(obj)
							end
						end
#					}
				}
			else
				all_collected = CollectedItem.get_collected_objects(get_curr_user_id)
				all_collected.each  { |uri,col|
					if !only_images || col['thumbnail']
						image = CachedResource.get_thumbnail_from_hit(col)
						image = view_context.image_path(DEFAULT_THUMBNAIL_IMAGE_PATH) if image == "" || image == nil
						ret.push({ :id => uri, :img => image, :title => col['title'], :strFirstLine => col['title'], :strSecondLine => col['author'] })
					end
				}
			end

			render :text => ret.to_json()
		else
			render :text => "Your session has expired. Please log in again.", :status => :bad_request
		end
	end

	def get_nines_obj_list_with_image
		params[:only_images] = true
		get_nines_obj_list()
	end

  private
  def post_object(thread, params, typ)
    disc_type = params[:disc_type]
    nines_object = params[:nines_object]
    inet_thumbnail = params[:inet_thumbnail]
    inet_url = params[:inet_url]
    inet_title = params[:inet_title]
    description = params[:description]
    nines_exhibit = params[:nines_exhibit]

    if ExhibitIllustration.get_illustration_type_nines_obj() == disc_type
      cr = CachedResource.find_by_uri(nines_object)
      if cr == nil  # if the object hadn't been collected, let's just go ahead an collect it
        CollectedItem.collect_item(current_user, nines_object, nil)
        cr = CachedResource.find_by_uri(nines_object)
      end
      DiscussionComment.create(:discussion_thread_id => thread.id, :user_id => get_curr_user_id, :position => 1,
        :comment_type => 'nines_object', :cached_resource_id => cr.id, :comment => description)
    elsif ExhibitIllustration.get_exhibit_type_text() == disc_type
      exhibit = Exhibit.find_by_title(nines_exhibit)
			exhibit = Exhibit.find_by_id(nines_exhibit) if exhibit == nil
      DiscussionComment.create(:discussion_thread_id => thread.id, :user_id => get_curr_user_id, :position => 1,
        :comment_type => 'nines_exhibit', :exhibit_id => exhibit.id, :comment => description)
    elsif ExhibitIllustration.get_illustration_type_image() == disc_type
      DiscussionComment.create(:discussion_thread_id => thread.id, :user_id => get_curr_user_id, :position => 1,
        :comment_type => 'inet_object', :link_url => inet_url, :link_title => inet_title, :image_url => inet_thumbnail, :comment => description)
    end
		DiscussionVisit.visited(thread, current_user)
		send_notification(thread.id, thread.group_id, thread.get_title(), get_curr_user_name, typ)
  end
  public
  
  def view_topic
    if params[:script]
      session[:script] = params[:script]
      params[:script] = nil
      redirect_to params
    else
      if session[:script]
        @script = session[:script]
        session[:script] = nil
      end
      session[:items_per_page] ||= MIN_ITEMS_PER_PAGE
      @page = params[:page] ? params[:page].to_i : 1
      @topic = DiscussionTopic.find(params[:topic])
      @threads = @topic.discussion_threads
      @threads = DiscussionThread.sort_by_time(@threads)
			user_id = get_curr_user_id()
			@threads = @threads.delete_if { |thread| !Group.can_read(thread, user_id) }

      @total = @threads.length
      @num_pages = @total.quo(session[:items_per_page]).ceil
      @page = @num_pages if @page == -1
      @page = 1 if @page == 0
      start = (@page-1) * session[:items_per_page]
      @threads = @threads.slice(start,session[:items_per_page])
    end
  end
  
  def view_thread
    if params[:script]
      session[:script] = params[:script]
			session[:uri] = params[:uri]
			session[:row_num] = params[:row_num]
			session[:row_id] = params[:row_id]
      params[:script] = nil
      params[:uri] = nil
      params[:row_num] = nil
      params[:row_id] = nil
      redirect_to params
    else
      if session[:script]
        @script = session[:script]
				@uri = session[:uri]
				@row_num = session[:row_num]
				@row_id = session[:row_id]

        session[:script] = nil
        session[:uri] = nil
        session[:row_num] = nil
        session[:row_id] = nil
      end
      retrieve_thread(params)
	  if @thread
		  num_views = @thread.number_of_views
		  num_views = 0 if num_views == nil
		  num_views += 1
		  @thread.update_attribute(:number_of_views, num_views)
				DiscussionVisit.visited(@thread, current_user)
				@subtitle = " : #{@thread.get_title()}"
	  else
		  # the thread has disappeared
		  redirect_to :controller => 'forum', :action => 'index'
	  end
    end
  end

  private
  def retrieve_thread(params)
    session[:items_per_page] ||= MIN_ITEMS_PER_PAGE
    thread_id = params[:thread]
    @thread = DiscussionThread.find_by_id(thread_id)
	if @thread
		@page = params[:page] ? params[:page].to_i : 1
		@replies = @thread.discussion_comments
		@total = @replies.length-1
		@num_pages = session[:items_per_page] != 0 ? @total.quo(session[:items_per_page]).ceil : 0
		@page = @num_pages if @page == -1
		@page = 1 if @page == 0
		start = (@page-1) * session[:items_per_page]
		@replies = @replies.slice(start+1,session[:items_per_page])
	end
  end
  public
  
  def delete_comment
    thread_id = -1
    if !user_signed_in?
      flash[:error] = 'You must be signed in to delete a comment.'
    else
			thread_id = DiscussionComment.delete_comment(params[:comment], current_user, is_admin?)
    end
    
    if thread_id == -1
      redirect_to :action => :index
    else
      redirect_to :action => :view_thread, :thread => thread_id
    end
  end
  
  def report_comment
    if !user_signed_in?
      flash[:error] = 'You must be signed in to report a comment.'
    else
      comment_id = params["comment_id"]
      reason = params['reason']
      can_edit = params['can_edit'] == 'true'
      can_delete = params['can_delete'] == 'true'
      is_main = params['is_main'] == 'true'
      comment = DiscussionComment.find(comment_id)
			if comment.has_been_reported_by(get_curr_user_id) == false
				comment.add_reporter(get_curr_user_id, reason)
				comment.save
				begin
				  admins = User.get_administrators
				  admins.each do | admin |
						body = "A comment by #{User.find(comment.user_id).fullname} has been reported by #{get_curr_user_name}. The text of the message is:\n\n"
						body += "#{self.class.helpers.strip_tags(comment.comment)}\n\n"
						body += "The reason for this report is:\n\n#{reason}"
						GenericMailer.generic(Setup.site_name(), Setup.return_email(), admin.fullname, admin.email,
						  "Comment Abuse Reported", body, url_for(:controller => 'home', :action => 'index', :only_path => false), "").deliver
					end
				rescue Exception => msg
					logger.error("**** ERROR: Can't send email: " + msg.message)
				end
			end
      render :partial => 'comment', :locals => { :comment => comment, :can_edit => can_edit, :can_delete => can_delete, :is_main => is_main }
    end
  end
  
  def rss
		 if DISALLOW_RSS
			 render :text => 'RSS disabled for this installation'
			 return
		 end
     thread_id = params[:thread]
     thread = DiscussionThread.find(thread_id)
     
     #@items = [ { :title => 'first', :description => 'this is the first'}, { :title => 'second', :description => 'another entry' } ]
     render :partial => 'rss', :locals => { :thread => thread }
  end
  
   def result_count
     session[:items_per_page] ||= MIN_ITEMS_PER_PAGE
     requested_items_per_page = params['search'] ? params['search']['result_count'].to_i : session[:items_per_page] 
     session[:items_per_page] = (requested_items_per_page <= MAX_ITEMS_PER_PAGE) ? requested_items_per_page : MAX_ITEMS_PER_PAGE
     redirect_to :back
   end
  
  def index
    if params[:script]
      session[:script] = params[:script]
      params[:script] = nil
      redirect_to params
    else
      if session[:script]
        @script = session[:script]
        session[:script] = nil
      end
      session[:discussion_topic_sort] ||= 'date'
    end
  end
  
  def sort_by_topic
     session[:discussion_topic_sort] = 'topic'
     redirect_to :back
  end
  
  def sort_by_date
     session[:discussion_topic_sort] = 'date'
     redirect_to :back
  end

  def get_all_topics
    ret = []
    # this returns a json object of all the topics and their ids
    topics = DiscussionTopic.all
    topics.each {|topic|
      ret.push({ :value => topic.id, :text => topic.topic })
    }
    render :text => ret.to_json()
  end

## GET /discussion_threads
#  # GET /discussion_threads.xml
#  def index
#    @discussion_threads = DiscussionThread.find(:all)
#
#    respond_to do |format|
#      format.html # index.html.erb
#      format.xml  { render :xml => @discussion_threads }
#    end
#  end
#
#  # GET /discussion_threads/1
#  # GET /discussion_threads/1.xml
#  def show
#    @discussion_thread = DiscussionThread.find(params[:id])
#
#    respond_to do |format|
#      format.html # show.html.erb
#      format.xml  { render :xml => @discussion_thread }
#    end
#  end
#
#  # GET /discussion_threads/new
#  # GET /discussion_threads/new.xml
#  def new
#    @discussion_thread = DiscussionThread.new
#
#    respond_to do |format|
#      format.html # new.html.erb
#      format.xml  { render :xml => @discussion_thread }
#    end
#  end
#
#  # GET /discussion_threads/1/edit
#  def edit
#    @discussion_thread = DiscussionThread.find(params[:id])
#  end
#
#  # POST /discussion_threads
#  # POST /discussion_threads.xml
#  def create
#    @discussion_thread = DiscussionThread.new(params[:discussion_thread])
#
#    respond_to do |format|
#      if @discussion_thread.save
#        flash[:notice] = 'DiscussionThread was successfully created.'
#        format.html { redirect_to(@discussion_thread) }
#        format.xml  { render :xml => @discussion_thread, :status => :created, :location => @discussion_thread }
#      else
#        format.html { render :action => "new" }
#        format.xml  { render :xml => @discussion_thread.errors, :status => :unprocessable_entity }
#      end
#    end
#  end
#
#  # PUT /discussion_threads/1
#  # PUT /discussion_threads/1.xml
#  def update
#    @discussion_thread = DiscussionThread.find(params[:id])
#
#    respond_to do |format|
#      if @discussion_thread.update_attributes(params[:discussion_thread])
#        flash[:notice] = 'DiscussionThread was successfully updated.'
#        format.html { redirect_to(@discussion_thread) }
#        format.xml  { head :ok }
#      else
#        format.html { render :action => "edit" }
#        format.xml  { render :xml => @discussion_thread.errors, :status => :unprocessable_entity }
#      end
#    end
#  end
#
#  # DELETE /discussion_threads/1
#  # DELETE /discussion_threads/1.xml
#  def destroy
#    @discussion_thread = DiscussionThread.find(params[:id])
#    @discussion_thread.destroy
#
#    respond_to do |format|
#      format.html { redirect_to(discussion_threads_url) }
#      format.xml  { head :ok }
#    end
#  end
end
