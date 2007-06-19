class ExhibitedResourcesController < ExhibitsBaseController
  
  in_place_edit_for_resource :exhibited_resource, :annotation

  def index
    @exhibited_resources = ExhibitedResource.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @exhibited_resources.to_xml }
    end
  end
  
  def move_higher
    move_item(:move_higher, "Moved Exhibited Resource Up.")
  end  
  def move_lower
    move_item(:move_lower, "Moved Exhibited Resource Down.")
  end  
  def move_to_top
    move_item(:move_to_top, "Moved Exhibited Resource to Top.")
  end  
  def move_to_bottom
    move_item(:move_to_bottom, "Moved Exhibited Resource to Bottom.")
  end
  def move_item(command, notice)
    @exhibited_resource = ExhibitedResource.find(params[:id])
    @exhibited_resource.__send__(command)
    logger.info("ExhibitedResource: #{command.to_s}: #{params[:id]}")
    flash[:notice] = notice
    page = params[:page] || 1
    redirect_to edit_page_path(:exhibit_id => params[:exhibit_id], :page_id => params[:page_id], :anchor => dom_id(@exhibited_resource))
  rescue
    logger.info("Error: #{command} with id=#{params[:id]} failed.")
    flash[:error] = "There was an error moving your resource."
    redirect_to edit_page_path(:exhibit_id => params[:exhibit_id], :page_id => params[:page_id])
  end
  private :move_item

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

    unless params[:new_resource].blank?
      uri = params[:new_resource].match('thumbnail_').post_match
      exhibited_section_id = params[:exhibited_section_id].to_i
      es = ExhibitedSection.find(exhibited_section_id)
      er = ExhibitedResource.new(:uri => uri)
      es.exhibited_resources << er
      es.exhibited_resources.last.move_to_top
      flash[:error] = "You now have a duplicate of that object in your collection." if es.page.exhibit.uris.include?(uri)
      flash[:notice] = "The Resource was successfully added."
    else
      flash[:error] = "No Resource could be added."
    end
    unless er.blank?
      redirect_to edit_page_url(:exhibit_id => es.page.exhibit, :id => es.page, :anchor => dom_id(er))
    else
      redirect_to edit_page_url(es.page.exhibit, es.page)
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
