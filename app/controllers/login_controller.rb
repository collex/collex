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

class LoginController < ApplicationController
  #before_filter :authorize, :except => [:login_controls, :login, :logout, :signup, :submit_signup, :reset_password, :clear_user, :verify_login, :account_help, :recover_username]
   before_filter :init_view_options
   
   def init_view_options # This controls how the layout portion of the page looks.
     @use_tabs = false
     @use_signin= false
     @site_section = :login
     return true
   end

  # We first just try to go back to the referrer page. That may not be available if the
  # session timed out and possibly in other cases. If the referrer page is not available,
  # just go back to the main page.
  helper_method :get_page_to_return_to
  def get_page_to_return_to()
    if request && request.env && request.env["HTTP_REFERER"] && request.env["HTTP_REFERER"] !~ /login/
      return request.env["HTTP_REFERER"]
    end
    return "/"
  end
   
    def login_controls  # This is called by html pages using ajax to render the login controls
      render :partial => '/common/login_slider', :locals => { :current_page => 'about' }
    end
  
  def verify_login
		name = params[:signin_username] ? params[:signin_username] : ""
		pass = params[:signin_password] ? params[:signin_password] : ""

		logged_in_user = COLLEX_MANAGER.login(name, pass)
		if logged_in_user
			session[:user] = logged_in_user
			render :text => "Logging in..." # since this doesn't set the status, the Ajax handler will request the page again
		else
			render :text => "Invalid user/password combination", :status => :bad_request
		end
  end
  
  def logout 
    session[:user] = nil 
    redirect_to get_page_to_return_to()
  end

  def reset_password
		if request.post? and params[:help_username] and params[:help_username].size > 0
			@user = COLLEX_MANAGER.reset_password(params[:help_username])
			if @user
				begin
					LoginMailer.deliver_password_reset(:controller => self, :user => @user)
					render :text => "A new password has been e-mailed to your registered address.", :status => :bad_request
				rescue Exception => msg
					logger.error("**** ERROR: Can't send email: " + msg)
					render :text => "There was a problem sending email. If this persists, report the problem to the administrator.", :status => :bad_request
				end
			else
				render :text => "There is no user by that name.", :status => :bad_request
			end
		else
			render :text => "Please enter a user name.", :status => :bad_request
		end
  end

  def recover_username
		if request.post? and params[:help_email] and params[:help_email].size > 0
			@user = COLLEX_MANAGER.find_by_email(params[:help_email])
			if @user != nil
				begin
					LoginMailer.deliver_recover_username(:controller => self, :user => @user)
					render :text => "Your user name has been e-mailed to your registered address.", :status => :bad_request
				rescue Exception => msg
					logger.error("**** ERROR: Can't send email: " + msg)
					render :text => "There was a problem sending email. If this persists, report the problem to the administrator.", :status => :bad_request
				end
			else
				render :text => "There is no user with that email address.", :status => :bad_request
			end
		else
			render :text => "Please enter an email address.", :status => :bad_request
		end
  end
  
  def submit_signup
		err_msg = verify_signup_params(params)
		if (err_msg == nil)
			render :text => "Creating account..." # since this doesn't set the status, the Ajax handler will request the page again
		else
			render :text => err_msg, :status => :bad_request
		end
  end
  
  private
  
  # this returns nil if the user was created, and an error message if not.
  def verify_signup_params(params)
    if params[:create_username]
      if params[:create_username] !~ /^\w+[\w.]+$/
        return "Invalid username, please use only alphanumeric characters, periods, and no spaces"
      end
      
      if params[:create_email] !~ /\@/
        return "An e-mail address is required"
      end
      
      begin
        if params[:create_password].strip == ""
          return "Password must not be blank"
        end
        if params[:create_password] == params[:create_password2]
          session[:user] = COLLEX_MANAGER.create_user(params[:create_username], params[:create_password].strip, params[:create_email])
          return nil
        else
          return "Passwords do not match"
        end
      rescue UsernameAlreadyExistsException => e
        return e.message
      end
    end
    # there shouldn't be a way to get here, but just in case, we'll consider that a failure.
    return "Unknown error"
  end
  
  
end
