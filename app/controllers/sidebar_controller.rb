TAG_INSTRUCTIONS = 'tag this item'
ANNOTATION_INSTRUCTIONS = 'annotate this item'
NUM_VISIBLE_TAGS = 30


class SidebarController < ApplicationController
  before_filter :authorize, :only => [:update, :collect, :remove]
  before_filter :check_authorize, :only => [:list, :cloud, :cloud, :detail]
  before_filter :save_state, :except => [:remove, :update, :atom, :clear_user]
  
  layout "sidebar"

  def permalink
    session[:sidebar_state] = {:action => params[:view], :params => {:type => params[:type], :value => params[:value], :user => params[:user], :objid => params[:objid]} }     
    render_component :controller => "search", :action => "browse"
  end

  def atom
    @items = COLLEX_MANAGER.objects_by_type(params[:type], params[:value], params[:user])
    @headers['Content-Type'] = 'application/atom+xml'
    render_without_layout
  end
  
  def cloud
    @cloud_freq = []
    
#     return if not params[:type]
    params[:type] ||= "tag"
    
    data = COLLEX_MANAGER.cloud(params[:type], params[:user])
    return if data == nil or data.size == 0
     
    # TODO: revisit the double sorting here, once to get the maximum frequency, and then again to sort alphabetically
    grouped_data = data.group_by(&:last)
    alphabetized_groups = grouped_data.each_value{ |group| group.sort!{ |x,y| x[0]<=>y[0] } }
    sorted_data = alphabetized_groups.sort.reverse
    @cloud_freq = sorted_data.inject([]){ |ar,val| ar.concat(val.last) }
#     @cloud_freq = data.sort {|a,b| b[1] <=> a[1]}
    
    if params[:max]
      @cloud_freq = @cloud_freq.first(params[:max].to_i)
    end
     
    max_freq = @cloud_freq[0][1]
#     @cloud_freq.sort!{|a,b| a[0] <=> b[0]}
     
    @bucket_size = max_freq.quo(10).ceil     
  end
  
  def list
    @data = []
    return unless params[:type] and params[:value]
    @data = COLLEX_MANAGER.objects_by_type(params[:type], params[:value], params[:user])
  end
  
  def detail
     user = session[:user]
     @object, @mlt, @collection_info = COLLEX_MANAGER.object_detail(params[:objid], user ? user[:username] : nil)
     if @object.nil?
       flash.now[:error] = "No object with that object ID could be found."
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
      interpretation = Interpretation.new(:object_uri => params[:objid])
      user.interpretations << interpretation
    end
    interpretation.annotation =  params[:annotation]
    interpretation.tag_list = params[:tags]
    interpretation.save!
    redirect_to :action => 'detail', :objid => params[:objid]
  end
  
  def remove
    user = User.find_by_username(session[:user][:username])
    interpretation = user.interpretations.find_by_object_uri(params[:objid])
    Interpretation.destroy(interpretation.id)    
    
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
