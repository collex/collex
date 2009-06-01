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

  def start_discussion
    if !is_logged_in?
      flash[:error] = 'You must be signed in to start a discussion.'
      redirect_to :action => :index
    end
  end
  
  def post_comment_to_new_thread
    if !is_logged_in?
      flash[:error] = 'You must be signed in to start a discussion.'
    else
      topic_id = params[:topic_id]
      title = params[:title]
      thread = DiscussionThread.create(:discussion_topic_id => topic_id, :title => title)

      params[:thread_id] = thread.id
      create_comment(params)
    end

    redirect_to :action => :index
  end
  
  def post_comment_to_existing_thread
    if !is_logged_in?
      flash[:error] = 'You must be signed in to post a comment.'
    else
      create_comment(params)
#      thread_id = params[:thread_id]
#      inet_thumbnail = params[:inet_thumbnail]
#      inet_url = params[:inet_url]
#      nines_object = params[:nines_obj_list]
#      nines_exhibit = params[:exhibit_list]
#      description = params[:reply]
#      disc_type = params[:obj_type]
#      user = User.find_by_username(session[:user][:username])
#      thread = DiscussionThread.find(thread_id)
#   
#      if disc_type == ''
#        DiscussionComment.create(:discussion_thread_id => thread_id, :user_id => user.id, :position => thread.discussion_comments.length, :comment_type => 'comment', :comment => description)
#      elsif disc_type == 'mycollection'
#        cr = CachedResource.find_by_uri(nines_object)
#        DiscussionComment.create(:discussion_thread_id => thread.id, :user_id => user.id, :position => 1, 
#          :comment_type => 'nines_object', :cached_resource_id => cr.id, :comment => description)
#      elsif disc_type == 'exhibit'
#        a = nines_exhibit.split('_')
#        exhibit = Exhibit.find(a[1])
#        DiscussionComment.create(:discussion_thread_id => thread.id, :user_id => user.id, :position => 1, 
#          :comment_type => 'nines_exhibit', :exhibit_id => exhibit.id, :comment => description)
#      elsif disc_type == 'weblink'
#        DiscussionComment.create(:discussion_thread_id => thread.id, :user_id => user.id, :position => 1, 
#          :comment_type => 'inet_object', :link_url => inet_url, :image_url => inet_thumbnail, :comment => description)
#      end
    end
    
    retrieve_thread({ :thread => params[:thread_id], :page => '-1' })
    render :partial => 'replies', :locals => { :total => @total, :page => @page, :replies => @replies, :num_pages => @num_pages, :thread => @thread }
#    redirect_to :action => :view_thread, :thread => thread_id
  end

  private
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
    render :text => "/forum/view_topic?page=#{num_pages}&topic=#{topic_id}"
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
          obj[:title] = hit['title'][0]
          obj[:strFirstLine] = hit['title'][0]
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
    session[:items_per_page] ||= 10
    @page = params[:page] ? params[:page].to_i : 1
    @topic = DiscussionTopic.find(params[:topic])
    @threads = @topic.discussion_threads
    @total = @threads.length
    @num_pages = @total.quo(session[:items_per_page]).ceil
    @page = @num_pages if @page == -1
    start = (@page-1) * session[:items_per_page]
    @threads = @threads.slice(start,session[:items_per_page])
  end
  
  def view_thread
    retrieve_thread(params)
    num_views = @thread.number_of_views
    num_views = 0 if num_views == nil
    num_views += 1
    @thread.update_attribute(:number_of_views, num_views)
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
    start = (@page-1) * session[:items_per_page]
    @replies = @replies.slice(start+1,session[:items_per_page])
  end
  public
  
  def delete_comment
    discussion_comment = DiscussionComment.find(params[:comment])
    thread_id = discussion_comment.discussion_thread_id
    
    if !is_logged_in?
      flash[:error] = 'You must be signed in to delete a comment.'
    else
      user = User.find_by_username(session[:user][:username])
      if !is_admin? && user.id != discussion_comment.id
        flash[:error] = 'You must own the comment to delete it.'
      else
        ok_to_delete = true
        redirect_to_index = false
        if discussion_comment.position == 1 # the first comment is privileged and will delete the thread
          if discussion_comment.discussion_thread.discussion_comments.length == 1 # only delete the first comment if there are no follow up comments
            discussion_comment.discussion_thread.destroy
            redirect_to_index = true
          else
            ok_to_delete = false
          end
        end
      end
      discussion_comment.destroy if ok_to_delete
    end
    
    if redirect_to_index
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
      comment = DiscussionComment.find(comment_id)
      comment.reported = 1
      comment.reporter_id = user.id
      comment.save
      # TODO-PER: actually send email at this point
      redirect_to :action => :view_thread, :thread => comment.discussion_thread_id
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
     session[:discussion_topic_sort] ||= 'date'
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
