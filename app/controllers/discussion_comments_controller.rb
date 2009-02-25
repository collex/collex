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

class DiscussionCommentsController < ApplicationController
  # GET /discussion_comments
  # GET /discussion_comments.xml
  def index
    @discussion_comments = DiscussionComment.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @discussion_comments }
    end
  end

  # GET /discussion_comments/1
  # GET /discussion_comments/1.xml
  def show
    @discussion_comment = DiscussionComment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @discussion_comment }
    end
  end

  # GET /discussion_comments/new
  # GET /discussion_comments/new.xml
  def new
    @discussion_comment = DiscussionComment.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @discussion_comment }
    end
  end

  # GET /discussion_comments/1/edit
  def edit
    @discussion_comment = DiscussionComment.find(params[:id])
  end

  # POST /discussion_comments
  # POST /discussion_comments.xml
  def create
    @discussion_comment = DiscussionComment.new(params[:discussion_comment])

    respond_to do |format|
      if @discussion_comment.save
        flash[:notice] = 'DiscussionComment was successfully created.'
        format.html { redirect_to(@discussion_comment) }
        format.xml  { render :xml => @discussion_comment, :status => :created, :location => @discussion_comment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @discussion_comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /discussion_comments/1
  # PUT /discussion_comments/1.xml
  def update
    @discussion_comment = DiscussionComment.find(params[:id])

    respond_to do |format|
      if @discussion_comment.update_attributes(params[:discussion_comment])
        flash[:notice] = 'DiscussionComment was successfully updated.'
        format.html { redirect_to(@discussion_comment) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @discussion_comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /discussion_comments/1
  # DELETE /discussion_comments/1.xml
  def destroy
    @discussion_comment = DiscussionComment.find(params[:id])
    @discussion_comment.destroy

    respond_to do |format|
      format.html { redirect_to(discussion_comments_url) }
      format.xml  { head :ok }
    end
  end
end
