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
  before_filter :authorize, :except => [:login, :logout, :signup, :submit_signup, :reset_password, :clear_user, :verify_login, :account_help, :recover_username]
   before_filter :init_view_options
   helper_method :get_page_to_return_to
   
   def get_page_to_return_to
     return session[:current_page] if session[:current_page]
     return request.env["HTTP_REFERER"] if request.env["HTTP_REFERER"]
     return "/"
   end
   
   def init_view_options # This controls how the layout portion of the page looks.
     @use_tabs = false
     @use_signin= false
     @site_section = :login
     return true
   end

  def login 
      session[:user] = nil 
  end 

  def verify_login
    if not params[:username]
      session[:user] = nil
      redirect_to({:controller => "login", :action => "login" })
      return
    end
    
    logged_in_user = COLLEX_MANAGER.login(params[:username], params[:password])
    if logged_in_user 
      session[:user] = logged_in_user
      flash[:refresh_page] = true
      #session[:users_collections] = CachedResource.get_all_of_users_collections(User.find_by_username(logged_in_user[:username])) # store all the user's tags so we don't have to search for them for each returned book.
      redirect_to get_page_to_return_to()
      return
    else 
      flash[:notice] = "Invalid user/password combination" 
    end
    redirect_to(:action => 'login')
  end
  
  def logout 
    session[:user] = nil 
    
    request.env["HTTP_REFERER"] =~ /exhibit/ ? redirect_to(exhibits_path) : redirect_to(get_page_to_return_to())
  end

  def change_account
    if params[:password]
      begin
        if params[:email] !~ /\@/
          flash.now[:notice] = "An e-mail address is required"
          return
        end
        if params[:password] == params[:password2]
          session[:user] = COLLEX_MANAGER.update_user(session[:user][:username], params[:password].strip, params[:fullname], params[:email])
          flash.now[:notice] = "Profile updated"
          redirect_to get_page_to_return_to()
          return
        else
          flash.now[:notice] = "Passwords do not match"
        end
      rescue UsernameAlreadyExistsException => e
        flash.now[:notice] = e.message
      end
    end
    # if there was an error, we fall through, so go back to the original action
    redirect_to :action => 'account'
  end
  
  def reset_password
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
  end

  def recover_username
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
  end
  
  def account
    
  end
  
  def account_help
    
  end
  
  def signup
    # This displays the signup form
  end
  
  def submit_signup
    if verify_signup_params(params)
      redirect_to get_page_to_return_to()
    else
      redirect_to :action => 'signup', :username => params[:username], :fullname => params[:fullname], :email => params[:email]
    end
  end
  
  private
  # this returns true if the user was created, and false if not.
  # if there is an error, a flash message is created.
  def verify_signup_params(params)
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
          session[:user] = COLLEX_MANAGER.create_user(params[:username], params[:password].strip, params[:fullname], params[:email])
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
end
