class ExhibitedResourcesController < ExhibitedItemsController
  
  in_place_edit_for_resource :exhibited_resource, :annotation

  def create
    @exhibited_resource = ExhibitedResource.new(params[:exhibited_resource])
    exhibited_section_id = params[:exhibited_section_id].to_i
    es = ExhibitedSection.find(exhibited_section_id)

    if params[:new_resource].blank?
      er = ExhibitedResource.new
      flash[:notice] = "The Text area was successfully created."
      #flash[:error] = "You now have a duplicate of that object in your collection." if es.page.exhibit.uris.include?(uri)
    else
      uri = params[:new_resource].match('thumbnail_').post_match
      er = ExhibitedResource.new(:uri => uri)
      flash[:notice] = "The Resource was successfully added."
      # flash[:error] = "No Resource could be added."
    end  
    es.exhibited_resources << er
    es.exhibited_resources.last.move_to_top
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
