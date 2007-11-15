##########################################################################
# Copyright 2007 Applied Research in Patacriticism and the University of Virginia
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

TAG_INSTRUCTIONS = 'one-word keywords'
ANNOTATION_INSTRUCTIONS = 'your annotations'
NUM_VISIBLE_TAGS = 50
NUM_VISIBLE_ITEMS = 5

class SidebarController < ApplicationController
  before_filter :authorize, :only => [:update, :collect, :remove]
  before_filter :check_authorize, :only => [:list, :cloud, :cloud, :detail]
  before_filter :save_state, :except => [:remove, :update, :atom, :clear_user]
  
  layout "sidebar"
  
  def index
    cloud
    render :action => "cloud"
  end

  def permalink_list
    @view = 'list'
    permalink
  end
  def permalink_cloud
    @view = 'cloud'
    permalink
  end
  def permalink_detail
    @view = 'detail'
    permalink
  end

  def permalink
    session[:sidebar_state] = {:action => @view, :params => {:type => params[:type], :value => params[:value], :user => params[:user], :objid => params[:objid]} }     
    render_component :controller => "search", :action => "browse"
  end

  def atom
    @items = COLLEX_MANAGER.objects_by_type(params[:type], params[:value], params[:user])
    @headers['Content-Type'] = 'application/atom+xml'
    render_without_layout
  end
  
  def cloud
    @cloud_freq = []
    
    params[:type] ||= "tag"
    
    data = COLLEX_MANAGER.cloud(params[:type], params[:user])
    return if data == nil or data.size == 0
     
    # This groups by count, sorts each group's items alphabetically, sorts the group numerically descending, then 
    # semi-flattens them into an array of arrays of pairs. We end up with the largest tags first, alphabetized.
    grouped_data = data.group_by(&:last)
    alphabetized_groups = grouped_data.each_value{ |group| group.sort!{ |x,y| x[0]<=>y[0] } }
    sorted_data = alphabetized_groups.sort.reverse
    @cloud_freq = sorted_data.inject([]){ |ar,val| ar.concat(val.last) }
    
    if params[:max]
      @cloud_freq = @cloud_freq.first(params[:max].to_i)
    end
     
    max_freq = @cloud_freq[0][1]     
    @bucket_size = max_freq.quo(10).ceil     
  end
  
  def list
    @data = []
    return unless params[:type] and params[:value]

    items_per_page = 5
    @page = params[:page] ? params[:page].to_i : 1
    @data = COLLEX_MANAGER.objects_by_type(params[:type], params[:value], params[:user], (@page - 1) * items_per_page, items_per_page)
    @num_pages = @data["total_hits"].to_i.quo(items_per_page).ceil
    @num_pages = 1 if @num_pages == 0  # makes UI better to say there is at least 1 page
  end
  
  def detail
    user = session[:user]
#     @object, @mlt, @collection_info = COLLEX_MANAGER.object_detail(params[:objid], user ? user[:username] : nil)
    @object = SolrResource.find_by_uri(params[:objid], {:user => (user ? user[:username] : nil)})
    if @object.nil?
      flash.now[:sidebar_error] = "No object with that object ID could be found."
      session[:sidebar_state] = nil
      logger.info("BAD PERMALINK objid: #{params[:objid]}")
      redirect_to :controller => "sidebar", :action => "cloud" and return 
    end
    if user
      user = User.find_by_username(user[:username])
      @interpretation = user.interpretations.find_by_object_uri(params[:objid]) || Interpretation.new
    else
      @interpretation = Interpretation.new
    end
  end

  def update
    user = User.find_by_username(session[:user][:username])
    interpretation = user.interpretations.find_by_object_uri(params[:objid])
    if not interpretation
      interpretation = user.interpretations.build(:object_uri => params[:objid])
    end
    interpretation.annotation =  params[:annotation]
    interpretation.tag_list = params[:tags]
    interpretation.save!
    solr = CollexEngine.new
    solr.update_collectables(user.username, params[:objid], interpretation.tags.collect { |tag| tag.name }, interpretation.annotation)
    solr.commit
    redirect_to :action => 'detail', :objid => params[:objid]
  end
  
  def remove
    user = User.find_by_username(session[:user][:username])
    interpretation = user.interpretations.find_by_object_uri(params[:objid])
    Interpretation.destroy(interpretation.id) if interpretation
    solr = CollexEngine.new
    solr.remove_collectables(user.username, params[:objid])
    solr.commit
    
    redirect_to :action => 'detail', :objid => params[:objid]
  end
  
  def clear_user
    jumpto = {:controller => "sidebar", :action => "cloud", :type => "tag"}
    if session[:sidebar_state]
      session[:sidebar_state][:params].delete "user"
      jumpto = {:controller => "sidebar", :action => session[:sidebar_state][:action]}
      jumpto.merge! session[:sidebar_state][:params]
    end
    
    redirect_to(jumpto)
  end
  
  private
  def check_authorize
    if params[:user] == "<mine>"
      if !session[:user]
        authorize
      else
        params[:user] = session[:user][:username]
      end
    end
  end
  
  def save_state
    sidebar_params = params.clone
    sidebar_params.delete "action"
    sidebar_params.delete "controller"
    session[:sidebar_state] = {:action => params["action"], :params => sidebar_params } 
  end

end
