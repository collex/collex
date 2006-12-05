class Admin::SiteController < ApplicationController
  before_filter :check_admin_privileges
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @site_pages, @sites = paginate :sites, :per_page => 10
  end

  def show
    @site = Site.find(params[:id])
  end

  def new
    @site = Site.new
  end

  def create
    @site = Site.new(params[:site])
    if @site.save
      flash[:notice] = 'Site was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @site = Site.find(params[:id])
  end

  def update
    @site = Site.find(params[:id])
    if @site.update_attributes(params[:site])
      flash[:notice] = 'Site was successfully updated.'
      redirect_to :action => 'show', :id => @site
    else
      render :action => 'edit'
    end
  end

  def destroy
    Site.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  private
  #TODO: move this to a general /admin area controller superclass
  def check_admin_privileges
    user = session[:user]
    if user and ['erikhatcher', 'duanegran', 'jamieorc'].include? user[:username]
      return
    end
    
    redirect_to "http://www.nines.org"
  end

end
