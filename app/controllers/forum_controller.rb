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
  layout 'nines'
  before_filter :init_view_options

   # Number of search results to display by default
   MIN_ITEMS_PER_PAGE = 10
   MAX_ITEMS_PER_PAGE = 30

    private
  def init_view_options
    @use_tabs = true
    @use_signin= true
    @site_section = :discuss
    @uses_yui = true
    return true
  end
  public

#  def start_discussion
#    if !is_logged_in?
#      flash[:error] = 'You must be signed in to start a discussion.'
#      redirect_to :action => :index
#    end
#  end
#  
  def post_comment_to_new_thread
    if !is_logged_in?
      render :text => 'You must be signed in to start a discussion.', :status => :bad_request
    else
			params[:title] = params[:title].strip()
			params[:reply] = params[:reply].strip()
			err_msg = has_title(params)
			err_msg = has_body(params) if err_msg == nil

			if err_msg
				render :text => err_msg, :status => :bad_request
			else
				topic_id = params[:topic_id]
				title = params[:title]
				thread = DiscussionThread.create(:discussion_topic_id => topic_id, :title => title)

				params[:thread_id] = thread.id
				create_comment(params)

		    redirect_to :action => :index
			end
    end
  end
  
  def post_comment_to_existing_thread
    if !is_logged_in?
      render :text => 'You must be signed in to reply to a thread.', :status => :bad_request
    else
			params[:reply] = params[:reply].strip()
			err_msg = has_body(params)
			if err_msg
				render :text => err_msg, :status => :bad_request
			else
				create_comment(params)
				retrieve_thread({ :thread => params[:thread_id], :page => '-1' })
				render :partial => 'replies', :locals => { :total => @total, :page => @page, :replies => @replies, :num_pages => @num_pages, :thread => @thread }
			end
    end
  end

  def edit_existing_comment
    comment_id = params[:comment_id]
    inet_thumbnail = params[:inet_thumbnail]
    inet_url = params[:inet_url]
    nines_object = params[:nines_obj_list]
    nines_exhibit = params[:exhibit_list]
    description = params[:reply]
    disc_type = params[:obj_type]
    title = params[:title]
    
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
        cr = CollectedItem.collect_item(user, nines_object)
      end
      comment.update_attributes(:comment_type => 'nines_object', :cached_resource_id => cr.id, :comment => description, :user_modified_at => Time.now)
    elsif disc_type == 'exhibit'
      a = nines_exhibit.split('_')
      exhibit = Exhibit.find(a[1])
      comment.update_attributes(:comment_type => 'nines_exhibit', :exhibit_id => exhibit.id, :comment => description, :user_modified_at => Time.now)
    elsif disc_type == 'weblink'
      comment.update_attributes(:comment_type => 'inet_object', :link_url => inet_url, :image_url => inet_thumbnail, :comment => description, :user_modified_at => Time.now)
    end
    
    if title.length > 0 && comment.position == 1
      thread = DiscussionThread.find(comment.discussion_thread_id)
      thread.update_attributes(:title => title)
    end
    
    render :partial => 'comment', :locals => { :comment => comment, :thread_id => comment.discussion_thread_id, :can_delete => false, :can_edit => true, :is_main => comment.position == 1 }
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

  def create_comment(params)
    thread_id = params[:thread_id]
    inet_thumbnail = params[:inet_thumbnail]
    inet_url = params[:inet_url]
    nines_object = params[:nines_obj_list]
    nines_exhibit = params[:exhibit_list]
    description = params[:reply]
    disc_type = params[:obj_type]
    user = User.find_by_username(session[:user][:username])
    thread = DiscussionThread.find(thread_id)
    
    # If an attachment was not selected, but the type expected an attachment, just change the type to regular comment
    if disc_type == 'mycollection' && nines_object.length == 0
      disc_type = ''
    elsif disc_type == 'exhibit' && nines_exhibit.length == 0
      disc_type = ''
    end
 
    if disc_type == ''
      DiscussionComment.create(:discussion_thread_id => thread_id, :user_id => user.id, :position => thread.discussion_comments.length+1, :comment_type => 'comment', :comment => description)
    elsif disc_type == 'mycollection'
      cr = CachedResource.find_by_uri(nines_object)
      if cr == nil  # if the object hadn't been collected, let's just go ahead an collect it
        cr = CollectedItem.collect_item(user, nines_object)
      end
      DiscussionComment.create(:discussion_thread_id => thread.id, :user_id => user.id, :position => thread.discussion_comments.length+1, 
        :comment_type => 'nines_object', :cached_resource_id => cr.id, :comment => description)
    elsif disc_type == 'exhibit'
      a = nines_exhibit.split('_')
      exhibit = Exhibit.find(a[1])
      DiscussionComment.create(:discussion_thread_id => thread.id, :user_id => user.id, :position => thread.discussion_comments.length+1, 
        :comment_type => 'nines_exhibit', :exhibit_id => exhibit.id, :comment => description)
    elsif disc_type == 'weblink'
      DiscussionComment.create(:discussion_thread_id => thread.id, :user_id => user.id, :position => thread.discussion_comments.length+1, 
        :comment_type => 'inet_object', :link_url => inet_url, :image_url => inet_thumbnail, :comment => description)
    end
  end
  
  public
  def post_object_to_new_thread
    if !is_logged_in?
      flash[:error] = 'You must be signed in to start a discussion.'
    else
      # There are two records that must be updated to create the new thread. If the second record
      # isn't created, then we need to back off the first one.
      topic_id = params[:topic_id]
      thread = DiscussionThread.create(:discussion_topic_id => topic_id, :title => params[:title])

      begin
        post_object(thread, params)
      rescue
        thread.destroy()
        flash[:error] = "We're sorry. An error occurred when attempting to start the discussion thread."
      end
    end

    # now tell the caller where the post landed so they can go there.
    session[:items_per_page] ||= 10
    threads = DiscussionTopic.find(topic_id).discussion_threads
    num_pages = threads.length.quo(session[:items_per_page]).ceil
    render :text => "/forum/view_topic?page=1&topic=#{topic_id}"
  end
  
#  def post_object_to_existing_thread
#    if !is_logged_in?
#      flash[:error] = 'You must be signed in to post an object.'
#    else
#      thread_id = params[:thread_id]
#      thread = DiscussionThread.find(thread_id)
#      post_object(thread, params)
#    end
#
#    redirect_to :action => :view_thread, :thread => thread_id
#  end
  
  def get_exhibit_list
    # This is called through ajax and wants a json object back.
    exhibits = Exhibit.get_all_published()
    ret = []
    exhibits.each { |exhibit|
      obj = {}
      obj[:id] = "id_#{exhibit.id}"
      obj[:img] = exhibit.thumbnail
      obj[:img] = DEFAULT_THUMBNAIL_IMAGE_PATH if obj[:img] == "" || obj[:img] == nil
      obj[:title] = exhibit.title
      obj[:strFirstLine] = exhibit.title
      obj[:strSecondLine] = ""
      ret.push(obj)
    }
    render :text => ret.to_json()
  end
  
  def get_nines_obj_list
    ret = []
    user = session[:user] ? User.find_by_username(session[:user][:username]) : nil
    if user
      objs = CollectedItem.all(:conditions => [ "user_id = ?", user.id ])
      objs.each {|obj|
        hit = CachedResource.get_hit_from_resource_id(obj.cached_resource_id)
        if hit != nil
          image = CachedResource.get_thumbnail_from_hit(hit)
          image = DEFAULT_THUMBNAIL_IMAGE_PATH if image == "" || image == nil
          obj = {}
          obj[:id] = hit['uri']
          obj[:img] = image
          obj[:title] = CachedResource.fix_char_set(hit['title'][0])
          obj[:strFirstLine] = CachedResource.fix_char_set(hit['title'][0])
          obj[:strSecondLine] = hit['role_AUT'] ? hit['role_AUT'].join(', ') : hit['role_ART'] ? hit['role_ART'].join(', ') : ''
          ret.push(obj)
        end
      }
      render :text => ret.to_json()
    else
      render :text => "Your session has expired. Please log in again.", :status => :bad_request
    end
  end
  
  private
  def post_object(thread, params)
    disc_type = params[:disc_type]
    nines_object = params[:nines_object]
    inet_thumbnail = params[:inet_thumbnail]
    inet_url = params[:inet_url]
    description = params[:description]
    nines_exhibit = params[:nines_exhibit]
    user = User.find_by_username(session[:user][:username])
    
    if ExhibitIllustration.get_illustration_type_nines_obj() == disc_type
      cr = CachedResource.find_by_uri(nines_object)
      if cr == nil  # if the object hadn't been collected, let's just go ahead an collect it
        CollectedItem.collect_item(user, nines_object)
        cr = CachedResource.find_by_uri(nines_object)
      end
      DiscussionComment.create(:discussion_thread_id => thread.id, :user_id => user.id, :position => 1, 
        :comment_type => 'nines_object', :cached_resource_id => cr.id, :comment => description)
    elsif ExhibitIllustration.get_exhibit_type_text() == disc_type
      exhibit = Exhibit.find_by_title(nines_exhibit)
      DiscussionComment.create(:discussion_thread_id => thread.id, :user_id => user.id, :position => 1, 
        :comment_type => 'nines_exhibit', :exhibit_id => exhibit.id, :comment => description)
    elsif ExhibitIllustration.get_illustration_type_image() == disc_type
      DiscussionComment.create(:discussion_thread_id => thread.id, :user_id => user.id, :position => 1, 
        :comment_type => 'inet_object', :link_url => inet_url, :image_url => inet_thumbnail, :comment => description)
    end
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
      session[:items_per_page] ||= 10
      @page = params[:page] ? params[:page].to_i : 1
      @topic = DiscussionTopic.find(params[:topic])
      @threads = @topic.discussion_threads
      @threads = @threads.sort {|a,b|
        b.discussion_comments[b.discussion_comments.length-1].updated_at <=> a.discussion_comments[a.discussion_comments.length-1].updated_at
      }
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
      num_views = @thread.number_of_views
      num_views = 0 if num_views == nil
      num_views += 1
      @thread.update_attribute(:number_of_views, num_views)
			@subtitle = " : #{@thread.get_title()}"
    end
  end

  private
  def retrieve_thread(params)
    session[:items_per_page] ||= 10
    thread_id = params[:thread]
    @thread = DiscussionThread.find(thread_id)
    @page = params[:page] ? params[:page].to_i : 1
    @replies = @thread.discussion_comments
    @total = @replies.length-1
    @num_pages = @total.quo(session[:items_per_page]).ceil
    @page = @num_pages if @page == -1
    @page = 1 if @page == 0
    start = (@page-1) * session[:items_per_page]
    @replies = @replies.slice(start+1,session[:items_per_page])
  end
  public
  
  def delete_comment
    thread_id = -1
    if !is_logged_in?
      flash[:error] = 'You must be signed in to delete a comment.'
    else
			thread_id = DiscussionComment.delete_comment(params[:comment], session[:user], is_admin?)
    end
    
    if thread_id == -1
      redirect_to :action => :index
    else
      redirect_to :action => :view_thread, :thread => thread_id
    end
  end
  
  def report_comment
    if !is_logged_in?
      flash[:error] = 'You must be signed in to delete a comment.'
    else
      user = User.find_by_username(session[:user][:username])
      comment_id = params["comment_id"]
      can_edit = params['can_edit'] == 'true'
      can_delete = params['can_delete'] == 'true'
      is_main = params['is_main'] == 'true'
      comment = DiscussionComment.find(comment_id)
			if comment.has_reporter(user.id) == false
				comment.reported = 1
				DiscussionComment.add_reporter(comment, user.id)
				comment.save
				begin
					ExceptionNotifier.exception_recipients.each { |ad|
						LoginMailer.deliver_report_abuse_to_admin({ :comment => comment }, ad)
					}
				rescue Exception => msg
					logger.error("**** ERROR: Can't send email: " + msg)
				end
			end
      render :partial => 'comment', :locals => { :comment => comment, :can_edit => can_edit, :can_delete => can_delete, :is_main => is_main }
      #redirect_to :action => :view_thread, :thread => comment.discussion_thread_id
    end
  end
  
  def rss
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
    topics = DiscussionTopic.find(:all)
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
