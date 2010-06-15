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

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  
  #session :session_key => "_nines_user_session"
  session_times_out_in 4.hours
  
  helper :all # include all helpers, all the time
  #protect_from_forgery # See ActionController::RequestForgeryProtection for details
  # Scrub sensitive parameters from your log
  filter_parameter_logging "password"
  
#  local_addresses.clear  #uncomment to test e-mails locally in development mode
  
  before_filter :set_charset
  before_filter :session_create
  
  helper_method :is_logged_in?, :username, :user,
                :is_admin?, :get_curr_user_id
  
  private
	def new_constraints_obj()
		return [ FederationConstraint.new(:field => 'federation', :value => DEFAULT_FEDERATION, :inverted => false) ]
	end

    def session_create
	    ActionMailer::Base.default_url_options[:host] = request.host_with_port
			ExceptionNotifier.email_prefix = ExceptionNotifier.email_prefix.gsub('*', ":#{request.host}")
      session[:constraints] ||= new_constraints_obj()
      session[:num_docs] ||= (CollexEngine.new).num_docs
      session[:num_docs] ||= 1000
			# This will write the log to the database. That is useful in deployments where you can't easily get to the log files.
      #Log.append_record(session, request.env, params)
    end
  
    def set_charset
      headers['Content-Type'] = 'text/html; charset=utf-8'
      headers['Pragma'] = 'no-cache'
      headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
    end
      
    def is_logged_in?
      session[:user] ? true : false
    end

    def is_admin?
      user = session[:user]
      if user and user[:role_names] and user[:role_names].include? 'admin'
        return true
      end
      return false
    end
  
    def username
      session[:user] ? session[:user][:username] : nil
    end
    
    def user
      username ? User.find_by_username(username) : nil
    end
    
		def get_curr_user
			user = session[:user]
			return nil if user == nil
			user = User.find_by_username(user[:username])
			return user
		end

		def get_curr_user_id
			user = session[:user]
			return nil if user == nil
			user = User.find_by_username(user[:username])
			return user.id
		end

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