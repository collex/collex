# The filters added to this controller will be run for all controllers in the application.
# Likewise will all the methods added be available for all controllers.
class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  
  filter_parameter_logging "password"
  
#  local_addresses.clear  #uncomment to test e-mails locally in development mode
  
  layout "common"
  
  before_filter :set_charset
  before_filter :session_create
  
  helper_method :me?, :all_users?, :other_user?, :is_logged_in?, :username, :my_username, :other_username, :user
  
  def boom
    raise "boom!"
  end
  
  private
    def session_create
      session[:constraints] ||= []
    end
  
    def set_charset
      headers['Content-Type'] = 'text/html; charset=utf-8'
      headers['Pragma'] = 'no-cache'
      headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
    end
      
    def authorize
      unless session[:user] 
        flash[:notice] = "please log in" 
      
        # save the URL the user requested so we can hop back to it after login
        session[:jumpto] = request.request_uri if not request.xhr?
      
        redirect_to(:controller => "login", :action => "login") 
      end 
    end 

    def is_logged_in?
      session[:user] ? true : false
    end

    def me?
      session[:user] ? (params[:user] == username) : false
    end
    
    def all_users?
      !params[:user]
    end
    
    def other_user?
      !me? and !all_users?
    end
    
    def other_username
      other_user? ? params[:user] : nil
    end

    def username
      session[:user] ? session[:user][:username] : nil
    end
    alias_method :my_username, :username
    
    def user
      my_username ? User.find_by_username(my_username) : nil
    end
    
    def self.in_place_edit_for_resource(object, attribute, options = {})
      define_method("update_#{attribute}") do
        @item = object.to_s.camelize.constantize.find(params[:id])
        @item.update_attribute(attribute, params[:value])
        render :text => @item.send(attribute)
      end
    end

end