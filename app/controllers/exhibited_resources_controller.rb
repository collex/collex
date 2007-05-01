class ExhibitedResourcesController < ApplicationController
  in_place_edit_for_resource :exhibited_resource, :annotation

  def index
    @exhibited_resources = ExhibitedResource.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @exhibited_resources.to_xml }
    end
  end
  
  def move_higher
    @exhibited_resource = ExhibitedResource.find(params[:id])
    @exhibited_resource.move_higher
    flash[:notice] = "Moved Exhibited Resource Up."
    redirect_after_move
  end  
  def move_lower
    @exhibited_resource = ExhibitedResource.find(params[:id])
    @exhibited_resource.move_lower
    flash[:notice] = "Moved Exhibited Resource Down."
    redirect_after_move
  end
  def redirect_after_move
    page = params[:page] || 1
    redirect_to edit_exhibit_path(:id => params[:exhibit_id], :anchor => dom_id(@exhibited_resource), :page => page)
  end
  private :redirect_after_move

  def show
    @exhibited_resource = ExhibitedResource.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @exhibited_resource.to_xml }
    end
  end

  def new
    @exhibited_resource = ExhibitedResource.new
  end

  def edit
    @exhibited_resource = ExhibitedResource.find(params[:id])
  end

  def create
    @exhibited_resource = ExhibitedResource.new(params[:exhibited_resource])

    respond_to do |format|
      if @exhibited_resource.save
        flash[:notice] = 'ExhibitedResource was successfully created.'
        format.html { redirect_to exhibited_resource_url(@exhibited_resource) }
        format.xml  { head :created, :location => exhibited_resource_url(@exhibited_resource) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @exhibited_resource.errors.to_xml }
      end
    end
  end

  def update
    @exhibited_resource = ExhibitedResource.find(params[:id])
    @exhibit = Exhibit.find(params[:exhibit_id])

    respond_to do |format|
      if @exhibited_resource.update_attributes(params[:exhibited_resource])
        flash[:notice] = 'Exhibited Resource was successfully updated.'
        format.html { redirect_to edit_exhibit_url(:id => @exhibit, :anchor => dom_id(@exhibited_resource)) }
        format.xml  { head :ok }
      else
        format.html { redirect_to edit_exhibit_url(@exhibit) }
        format.xml  { render :xml => @exhibited_resource.errors.to_xml }
      end
    end
  end

  def destroy
    @exhibited_resource = ExhibitedResource.find(params[:id])
    @exhibit = Exhibit.find(params[:exhibit_id])
    @exhibited_resource.destroy

    respond_to do |format|
      flash[:notice] = 'Exhibited Resource was successfully removed.'
      page = params[:page] || 1
      format.html { redirect_to edit_exhibit_url(:id => @exhibit, :page => page) }
      format.xml  { head :ok }
    end
  end
end
