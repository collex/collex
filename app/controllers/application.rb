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

# The filters added to this controller will be run for all controllers in the application.
# Likewise will all the methods added be available for all controllers.
class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  
  session :session_key => "_nines_user_session"
  session_times_out_in 30.minutes
  
  filter_parameter_logging "password"
  
#  local_addresses.clear  #uncomment to test e-mails locally in development mode
  
  layout "common"
  
  before_filter :set_charset
  before_filter :session_create
  
  helper_method :me?, :all_users?, :other_user?, :is_logged_in?, :username, :my_username, :other_username, :user, :user_or_guest,
                :safari?
  
  def boom
    raise "boom!"
  end
  
  private
    def session_create
      session[:constraints] ||= []
      session[:num_docs] ||= (CollexEngine.new).num_docs
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
      
        redirect_to(:controller => "login", :action => "login") and return false
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
    
    def user_or_guest
      user || Guest.new
    end
    
    def safari?
      request.env['HTTP_USER_AGENT'].downcase.index('safari') != nil
    end
    
    def self.in_place_edit_for_resource(object, attribute, options = {})
      define_method("update_#{attribute}") do
        @item = object.to_s.camelize.constantize.find(params[:id])
        @item.update_attribute(attribute, params[:value])
        render :text => @item.send(attribute)
      end
    end
    
    # for debugging rescue_action_in_public
    # def local_request?
    #     false
    # end
    
    def rescue_action_in_public(exception)
      case exception
        when ::ActiveRecord::RecordNotFound, ::ActionController::UnknownController, ::ActionController::UnknownAction, ::ActionController::RoutingError
          render_404

        else          
          render_500

          deliverer = self.class.exception_data
          data = case deliverer
            when nil then {}
            when Symbol then send(deliverer)
            when Proc then deliverer.call(self)
          end

          ExceptionNotifier.deliver_exception_notification(exception, self,
            request, data)
      end
    end

end