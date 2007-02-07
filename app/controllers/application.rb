# The filters added to this controller will be run for all controllers in the application.
# Likewise will all the methods added be available for all controllers.
class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  
  filter_parameter_logging "password"
  
#  local_addresses.clear  #uncomment to test e-mails locally in development mode
  
  layout "common"
  
  before_filter :set_charset
  before_filter :session_create
  
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
end