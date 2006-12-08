class Admin::LicensesController < Admin::BaseController

  def index
    @license_pages, @licenses = paginate :licenses, :per_page => 10
  end

  def new
    @license = License.new
  end
  
  def create
    @license = License.new(params[:license])
    if @license.save
      flash[:notice] = 'License was successfully created.'
      redirect_to :action => 'index'
    else
      flash[:warning] = "License was not created."
      render :action => 'new'
    end
  end

  def edit
    @license = License.find(params[:id])
  end
  
  def update
    @license = License.find(params[:id])
    if @license.update_attributes(params[:license])
      flash[:notice] = 'License was successfully updated.'
    else
      flash[:warning] = "License was not updated."
    end  
    redirect_to :action => 'show', :id => @license
  end

  def show
    @license = License.find(params[:id])
  end
  
  def destroy
    License.destroy(params[:id])
    flash[:notice] = "License was successfully destroyed."
    redirect_to :action => 'index'
  end
end
