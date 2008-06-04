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
    headers['Content-Type'] = 'application/atom+xml'
    render :layout => nil
  end
  
  def cloud
    params[:type] ||= "tag"
    
    @cloud_fragment_key = cloud_fragment_key(params[:type], params[:user], params[:max])
    
    if is_cache_expired?(@cloud_fragment_key)
      @cloud_freq = CachedResource.cloud(params[:type], User.find_by_username(params[:user]), params[:max])
      unless @cloud_freq.empty?
        max_freq = 1
        @cloud_freq.each { |entry| 
          max_freq = entry[1] > max_freq ? entry[1] : max_freq 
        }
        @bucket_size = max_freq.quo(10).ceil
      end     
    end
  end
  
  def list
    @data = []
    return unless params[:type] and params[:value]
    items_per_page = 5
    @page = params[:page] ? params[:page].to_i : 1
    offset = (@page - 1) * items_per_page
    @data, @total_hits = CachedResource.list_from_cloud_tag(params[:type], params[:value], User.find_by_username(params[:user]), offset, items_per_page )
    @num_pages = @total_hits.quo(items_per_page).ceil
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
  
   def cloud_fragment_key( type, user, max )
     "/cloud/#{user}_user/#{type}_#{max}_sidebar"
   end

end
