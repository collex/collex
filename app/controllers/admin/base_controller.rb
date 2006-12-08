class Admin::BaseController < ApplicationController
  layout 'admin'
  before_filter :check_admin_privileges
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }
  

  private
  #TODO: move this to a general /admin area controller superclass
  def check_admin_privileges
    user = session[:user]
    if user and user[:role_names].include? 'admin'
      return
    end

    redirect_to "/collex"
  end

end
