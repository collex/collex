##########################################################################
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
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
  layout "bare"
  before_filter :authorize, :except => [:login, :logout, :signup, :reset_password]

  def login 
    if not params[:username]
      session[:user] = nil 
    else 
      logged_in_user = COLLEX_MANAGER.login(params[:username], params[:password])
      if logged_in_user 
        session[:user] = logged_in_user
        jumpto = session[:jumpto]
        if not session[:jumpto]
          if session[:sidebar_state]
            jumpto = {:controller => "sidebar", :action => session[:sidebar_state][:action]}
            jumpto.merge! session[:sidebar_state][:params]
          else
            jumpto = {:controller => "sidebar", :action => "cloud", :type => "tag"}
          end
        end
        session[:jumpto] = nil
        flash[:refresh_page] = true
        redirect_to(jumpto)
      else 
        flash[:sidebar_notice] = "Invalid user/password combination" 
      end 
    end
    
    if session[:jumpto] =~ /\/collection\/collect/ and not request.xhr?
      render :action => "standalone_login"
    elsif session[:jumpto] =~ /\/exhibits?\// and not request.xhr?
      render :action => "full_login", :layout => "collex"
    end 
  end 

  def logout 
    session[:user] = nil 
    request.env["HTTP_REFERER"] =~ /exhibit/ ? redirect_to(exhibits_path) : redirect_to(:controller => "search", :action => "browse")
  end

  def account
    if params[:password]
      begin
        if params[:email] !~ /\@/
          flash.now[:sidebar_error] = "An e-mail address is required"
          return
        end
        if params[:password] == params[:password2]
          session[:user] = COLLEX_MANAGER.update_user(session[:user][:username], params[:password].strip, params[:fullname], params[:email])
          flash.now[:sidebar_message] = "Profile updated"
          render_component(session[:sidebar_state] ? {:controller => "sidebar", :action => session[:sidebar_state][:action], :params => session[:sidebar_state][:params]}: {:controller => 'sidebar', :action => 'cloud', :params => {:user => session[:user][:username], :type => "genre"}})
          return
        else
          flash.now[:sidebar_error] = "Passwords do not match"
        end
      rescue UsernameAlreadyExistsException => e
        flash.now[:sidebar_error] = e.message
      end
    end
     
  end
  
  def reset_password
    if request.post? and params[:username] and params[:username].size > 0
      @user = COLLEX_MANAGER.reset_password(params[:username])
      LoginMailer.deliver_password_reset(:controller => self, :user => @user) if @user
    end
  end

  
  def signup
    if params[:username]
      if params[:username] !~ /^\w+[\w.]+$/
        flash.now[:sidebar_error] = "Invalid username, please use only alphanumeric characters, periods, and no spaces"
        return
      end
      
      if params[:email] !~ /\@/
        flash.now[:sidebar_error] = "An e-mail address is required"
        return
      end
      
      begin
        if params[:password].strip == ""
          flash.now[:sidebar_error] = "Password must not be blank"
          return
        end
        if params[:password] == params[:password2]
          session[:user] = COLLEX_MANAGER.create_user(params[:username], params[:password].strip, params[:fullname], params[:email])
          flash[:refresh_page] = true
          redirect_to({:controller => "sidebar", :action => "cloud", :type => "genre"})
        else
          flash.now[:sidebar_error] = "Passwords do not match"
        end
      rescue UsernameAlreadyExistsException => e
        flash.now[:sidebar_error] = e.message
      end
    end
     
  end
end
