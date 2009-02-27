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

class DiscussionThreadsController < ApplicationController
  layout 'collex_tabs'
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
      comment = params[:comment]
      user = User.find_by_username(session[:user][:username])
      
      thread = DiscussionThread.create(:discussion_topic_id => topic_id, :title => title)
      DiscussionComment.create(:discussion_thread_id => thread.id, :user_id => user.id, :position => 1, :comment_type => 'comment', :comment => comment)
    end

    redirect_to :action => :index
  end
  
  def post_object_to_new_thread
    if !is_logged_in?
      flash[:error] = 'You must be signed in to start a discussion.'
    else
      topic_id = params[:topic_id]
      disc_type = params[:disc_type]
      nines_object = params[:nines_object]
      inet_thumbnail = params[:inet_thumbnail]
      inet_url = params[:inet_url]
      inet_description = params[:inet_description]
      nines_exhibit = params[:nines_exhibit]
      user = User.find_by_username(session[:user][:username])
      
      if ExhibitIllustration.get_illustration_type_nines_obj() == disc_type
        thread = DiscussionThread.create(:discussion_topic_id => topic_id, :title => "")
        cr = CachedResource.find_by_uri(nines_object)
        DiscussionComment.create(:discussion_thread_id => thread.id, :user_id => user.id, :position => 1, 
          :comment_type => 'nines_object', :cached_resource_id => cr.id)
      elsif ExhibitIllustration.get_exhibit_type_text() == disc_type
        exhibit = Exhibit.find_by_title(nines_exhibit)
        thread = DiscussionThread.create(:discussion_topic_id => topic_id, :title => "")
        DiscussionComment.create(:discussion_thread_id => thread.id, :user_id => user.id, :position => 1, 
          :comment_type => 'nines_exhibit', :exhibit_id => exhibit.id)
      elsif ExhibitIllustration.get_illustration_type_image() == disc_type
        thread = DiscussionThread.create(:discussion_topic_id => topic_id, :title => "")
        DiscussionComment.create(:discussion_thread_id => thread.id, :user_id => user.id, :position => 1, 
          :comment_type => 'inet_object', :link_url => inet_url, :image_url => inet_thumbnail, :comment => inet_description)
      end
    end

    redirect_to :action => :index
  end
  
  def view_thread
    thread_id = params[:thread]
    @thread = DiscussionThread.find(thread_id)
  end
  
# GET /discussion_threads
  # GET /discussion_threads.xml
  def index
    @discussion_threads = DiscussionThread.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @discussion_threads }
    end
  end

  # GET /discussion_threads/1
  # GET /discussion_threads/1.xml
  def show
    @discussion_thread = DiscussionThread.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @discussion_thread }
    end
  end

  # GET /discussion_threads/new
  # GET /discussion_threads/new.xml
  def new
    @discussion_thread = DiscussionThread.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @discussion_thread }
    end
  end

  # GET /discussion_threads/1/edit
  def edit
    @discussion_thread = DiscussionThread.find(params[:id])
  end

  # POST /discussion_threads
  # POST /discussion_threads.xml
  def create
    @discussion_thread = DiscussionThread.new(params[:discussion_thread])

    respond_to do |format|
      if @discussion_thread.save
        flash[:notice] = 'DiscussionThread was successfully created.'
        format.html { redirect_to(@discussion_thread) }
        format.xml  { render :xml => @discussion_thread, :status => :created, :location => @discussion_thread }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @discussion_thread.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /discussion_threads/1
  # PUT /discussion_threads/1.xml
  def update
    @discussion_thread = DiscussionThread.find(params[:id])

    respond_to do |format|
      if @discussion_thread.update_attributes(params[:discussion_thread])
        flash[:notice] = 'DiscussionThread was successfully updated.'
        format.html { redirect_to(@discussion_thread) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @discussion_thread.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /discussion_threads/1
  # DELETE /discussion_threads/1.xml
  def destroy
    @discussion_thread = DiscussionThread.find(params[:id])
    @discussion_thread.destroy

    respond_to do |format|
      format.html { redirect_to(discussion_threads_url) }
      format.xml  { head :ok }
    end
  end
end
