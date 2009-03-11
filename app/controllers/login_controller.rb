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
  layout "collex_tabs"
  before_filter :authorize, :except => [:login_controls, :login, :logout, :signup, :submit_signup, :reset_password, :clear_user, :verify_login, :account_help, :recover_username]
   before_filter :init_view_options
   
   def init_view_options # This controls how the layout portion of the page looks.
     @use_tabs = false
     @use_signin= false
     @site_section = :login
     @uses_separate_pages = true
     return true
   end

  # TODO-PER: old way
  helper_method :get_page_to_return_to
  def get_page_to_return_to()
    return session[:current_page] if session && session[:current_page]

    if request && request.env && request.env["HTTP_REFERER"] && request.env["HTTP_REFERER"] !~ /login/
      return request.env["HTTP_REFERER"]
    end
    return "/"
  end
  # TODO-PER: end old way
   
    def login_controls
      render :partial => '/common/login_slider'
    end
  
  def verify_login
    if @uses_separate_pages # TODO-PER: old way
      if not params[:username]
        session[:user] = nil
        redirect_to({:controller => "login", :action => "login" })
        return
      end
      
      logged_in_user = COLLEX_MANAGER.login(params[:username], params[:password])
      if logged_in_user 
        session[:user] = logged_in_user
        flash[:refresh_page] = true
        redirect_to get_page_to_return_to()
        return
      else 
        flash[:notice] = "Invalid user/password combination" 
      end
      redirect_to(:action => 'login')
      
    else  # javascript version
      name = params[:signin_username]
      pass = params[:signin_password]
      
      logged_in_user = COLLEX_MANAGER.login(name, pass)
      if logged_in_user 
        session[:user] = logged_in_user
        render :text => "Logging in..." # since this doesn't set the status, the Ajax handler will request the page again
      else 
        render :text => "Invalid user/password combination", :status => :bad_request
      end
    end
  end
  
  def logout 
    session[:user] = nil 
    redirect_to request.env["HTTP_REFERER"]
  end

  def change_account
    if @uses_separate_pages # TODO-PER: old way
      if params[:password]
        begin
          if params[:email] !~ /\@/
            flash[:notice] = "An e-mail address is required"
            return
          end
          if params[:password] == params[:password2]
            session[:user] = COLLEX_MANAGER.update_user(session[:user][:username], params[:password].strip, params[:email])
            flash[:notice] = "Profile updated"
            redirect_to get_page_to_return_to()
            return
          else
            flash[:notice] = "Passwords do not match"
          end
        rescue UsernameAlreadyExistsException => e
          flash[:notice] = e.message
        end
      end
      # if there was an error, we fall through, so go back to the original action
      redirect_to :action => 'account'

    else  # javascript version
      if request.post?
        begin
          if params[:account_email] !~ /\@/
            render :text => "An e-mail address is required", :status => :bad_request
            return
          end
          if params[:account_password] == params[:account_password2]
            session[:user] = COLLEX_MANAGER.update_user(session[:user][:username], params[:account_password].strip, params[:account_email])
            render :text => "Profile updated", :status => :bad_request
          else
            render :text => "Passwords do not match", :status => :bad_request
          end
        rescue UsernameAlreadyExistsException => e
          render :text => e.message, :status => :bad_request
        end
      end
    end
  end
  
  def reset_password
    if @uses_separate_pages # TODO-PER: old way
      if request.post? and params[:username] and params[:username].size > 0
        @user = COLLEX_MANAGER.reset_password(params[:username])
        if @user
          begin
            LoginMailer.deliver_password_reset(:controller => self, :user => @user)
          rescue Exception => msg
            logger.error("**** ERROR: Can't send email: " + msg)
            flash[:notice] = "There was a problem sending email. If this persists, report the problem to the administrator."
            redirect_to :action => 'account_help', :username => params[:username]
          end
        else
          flash[:notice] = "There is no user by that name."
          redirect_to :action => 'account_help', :username => params[:username]
        end
      end
      
    else  # javascript version
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
  end

  def recover_username
    if @uses_separate_pages # TODO-PER: old way
      if request.post? and params[:email] and params[:email].size > 0
        @user = COLLEX_MANAGER.find_by_email(params[:email])
        if @user != nil
          begin
            LoginMailer.deliver_recover_username(:controller => self, :user => @user)
          rescue Exception => msg
            logger.error("**** ERROR: Can't send email: " + msg)
            flash[:notice] = "There was a problem sending email. If this persists, report the problem to the administrator."
            redirect_to :action => 'account_help', :username => params[:username]
          end
        else
          flash[:notice] = "There is no user with that email address."
          redirect_to :action => 'account_help', :email => params[:email]
        end
      end
    else  # javascript version
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
  end
  
  def submit_signup
    if @uses_separate_pages # TODO-PER: old way
      if verify_signup_params_old(params)
        redirect_to get_page_to_return_to()
      else
        redirect_to :action => 'signup', :username => params[:username], :email => params[:email]
      end
      
    else  # javascript version
      err_msg = verify_signup_params(params)
      if (err_msg == nil)
        render :text => "Creating account..." # since this doesn't set the status, the Ajax handler will request the page again
      else 
        render :text => err_msg, :status => :bad_request
      end
    end
  end
  
  private
  
  def verify_signup_params_old(params)  #TODO-PER: old way
    if params[:username]
      if params[:username] !~ /^\w+[\w.]+$/
        flash[:notice] = "Invalid username, please use only alphanumeric characters, periods, and no spaces"
        return false
      end
      
      if params[:email] !~ /\@/
        flash[:notice] = "An e-mail address is required"
        return false
      end
      
      begin
        if params[:password].strip == ""
          flash[:notice] = "Password must not be blank"
          return false
        end
        if params[:password] == params[:password2]
          session[:user] = COLLEX_MANAGER.create_user(params[:username], params[:password].strip, params[:email])
          flash[:refresh_page] = true
          return true
        else
          flash[:notice] = "Passwords do not match"
          return false
        end
      rescue UsernameAlreadyExistsException => e
        flash[:notice] = e.message
        return false
      end
    end
    # there shouldn't be a way to get here, but just in case, we'll consider that a failure.
    return false
  end

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
