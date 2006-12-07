class Admin::UserRolesController < ApplicationController
  layout 'admin'
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @user_pages, @users = paginate :users, :per_page => 10
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
    @roles = Role.find :all
  end

  def update
    @user = User.find(params[:id])
    @roles = Role.find :all
    roles_hash = {}
    @roles.each { |role| roles_hash["user_role_#{role.name}"] = role }
    user_roles = roles_hash.reject { |k,v| !params.has_key? k }.values
    @user.roles = user_roles
    
    if @user.save
      flash[:notice] = 'User was successfully updated.'
      redirect_to :action => 'edit', :id => @user
    else
      render :action => 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
