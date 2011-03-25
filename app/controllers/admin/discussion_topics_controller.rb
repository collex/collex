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

class Admin::DiscussionTopicsController < Admin::BaseController
  # GET /discussion_topics
  # GET /discussion_topics.xml
  def index
    @discussion_topics = DiscussionTopic.all(:order => 'position')
  end

#  # GET /discussion_topics/1
#  # GET /discussion_topics/1.xml
#  def show
#    @discussion_topic = DiscussionTopic.find(params[:id])
#
#    respond_to do |format|
#      format.html # show.html.erb
#      format.xml  { render :xml => @discussion_topic }
#    end
#  end

  # GET /discussion_topics/new
  # GET /discussion_topics/new.xml
  def new
    @discussion_topic = DiscussionTopic.new
  end

  # GET /discussion_topics/1/edit
  def edit
    @discussion_topic = DiscussionTopic.find(params[:id])
  end

  # POST /discussion_topics
  # POST /discussion_topics.xml
  def create
    @discussion_topic = DiscussionTopic.new(params[:discussion_topic])
    @discussion_topic.position = DiscussionTopic.count + 1

    respond_to do |format|
      if @discussion_topic.save
        flash[:notice] = 'DiscussionTopic was successfully created.'
        format.html { redirect_to(:action => 'index') }
        format.xml  { render :xml => @discussion_topic, :status => :created, :location => @discussion_topic }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @discussion_topic.errors, :status => :unprocessable_entity }
      end
    end
  end

  def move_up
    @discussion_topic = DiscussionTopic.find(params[:id])
    pos = @discussion_topic.position
    if pos > 1
      prev = DiscussionTopic.find_by_position(pos-1)
      if prev
        prev.position = prev.position + 1
        prev.save
      end
      @discussion_topic.position = @discussion_topic.position - 1
      @discussion_topic.save
    end
    redirect_to :action => 'index'
  end
  
  def move_down
    @discussion_topic = DiscussionTopic.find(params[:id])
    pos = @discussion_topic.position
    if pos < DiscussionTopic.count
      nex = DiscussionTopic.find_by_position(pos+1)
      if nex
        nex.position = nex.position - 1
        nex.save
      end
      @discussion_topic.position = @discussion_topic.position + 1
      @discussion_topic.save
    end
    redirect_to :action => 'index'
  end
  
  # PUT /discussion_topics/1
  # PUT /discussion_topics/1.xml
  def update
    @discussion_topic = DiscussionTopic.find(params[:id])

    respond_to do |format|
      if @discussion_topic.update_attributes(params[:discussion_topic])
        flash[:notice] = 'DiscussionTopic was successfully updated.'
        format.html { redirect_to(:action => 'index') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @discussion_topic.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /discussion_topics/1
  # DELETE /discussion_topics/1.xml
  def destroy
    @discussion_topic = DiscussionTopic.find(params[:id])
    pos = @discussion_topic.position
    @discussion_topic.destroy
    
    topics = DiscussionTopic.all()
    topics.each do |topic|
      if topic.position > pos
        topic.position = topic.position - 1
        topic.save
      end
    end

    respond_to do |format|
      format.html { redirect_to(:action => 'index') }
      format.xml  { head :ok }
    end
  end
end
