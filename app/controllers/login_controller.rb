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
        flash[:notice] = "Invalid user/password combination" 
      end 
    end
    
    if (session[:jumpto] =~ /\/collection\/collect/ || session[:jumpto] =~ /\/exhibit\//) and not request.xhr?
      render :action => "standalone_login"
    end 
  end 

  def logout 
    session[:user] = nil 
    redirect_to(:controller => "search", :action => "browse") 
  end

  def account
    if params[:password]
      begin
        if params[:email] !~ /\@/
          flash.now[:error] = "An e-mail address is required"
          return
        end
        if params[:password] == params[:password2]
          session[:user] = COLLEX_MANAGER.update_user(session[:user][:username], params[:password].strip, params[:fullname], params[:email])
          flash.now[:message] = "Profile updated"
          render_component(session[:sidebar_state] ? {:controller => "sidebar", :action => session[:sidebar_state][:action], :params => session[:sidebar_state][:params]}: {:controller => 'sidebar', :action => 'cloud', :params => {:user => session[:user][:username], :type => "genre"}})
          return
        else
          flash.now[:error] = "Passwords do not match"
        end
      rescue UsernameAlreadyExistsException => e
        flash.now[:error] = e.message
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
      if params[:username] !~ /^\w*$/
        flash.now[:error] = "Invalid username, please use only alphanumeric characters and no spaces"
        return
      end
      
      if params[:email] !~ /\@/
        flash.now[:error] = "An e-mail address is required"
        return
      end
      
      begin
        if params[:password].strip == ""
          flash.now[:error] = "Password must not be blank"
          return
        end
        if params[:password] == params[:password2]
          session[:user] = COLLEX_MANAGER.create_user(params[:username], params[:password].strip, params[:fullname], params[:email])
          flash[:refresh_page] = true
          redirect_to({:controller => "sidebar", :action => "cloud", :type => "genre"})
        else
          flash.now[:error] = "Passwords do not match"
        end
      rescue UsernameAlreadyExistsException => e
        flash.now[:error] = e.message
      end
    end
     
  end
end
