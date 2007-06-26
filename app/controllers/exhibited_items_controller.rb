class ExhibitedItemsController < ExhibitsBaseController
  in_place_edit_for_resource :exhibited_item, :annotation

  def move_higher
    move_item(:move_higher, "Moved Exhibited Item Up.")
  end  
  def move_lower
    move_item(:move_lower, "Moved Exhibited Item Down.")
  end  
  def move_to_top
    move_item(:move_to_top, "Moved Exhibited Item to Top.")
  end  
  def move_to_bottom
    move_item(:move_to_bottom, "Moved Exhibited Item to Bottom.")
  end
  def move_item(command, notice)
    @exhibited_item = ExhibitedItem.find(params[:id])
    @exhibited_item.__send__(command)
    logger.info("ExhibitedItem: #{command.to_s}: #{params[:id]}")
    flash[:notice] = notice
    redirect_to edit_page_path(:exhibit_id => params[:exhibit_id], :id => params[:page_id], :anchor => dom_id(@exhibited_item))
  rescue Exception
    logger.info("Error: #{command} with id=#{params[:id]} failed.")
    flash[:error] = "There was an error moving your item."
    redirect_to edit_page_path(:exhibit_id => params[:exhibit_id], :id => params[:page_id])
  end
  private :move_item
  def create
    @exhibited_item = ExhibitedItem.new(params[:exhibited_item])
    exhibited_section_id = params[:exhibited_section_id].to_i
    es = ExhibitedSection.find(exhibited_section_id)

    if params[:new_item].blank?
      er = ExhibitedItem.new
      flash[:notice] = "The Text area was successfully created."
      #flash[:error] = "You now have a duplicate of that object in your collection." if es.page.exhibit.uris.include?(uri)
    else
      uri = params[:new_item].match('thumbnail_').post_match
      er = ExhibitedItem.new(:uri => uri)
      flash[:notice] = "The Item was successfully added."
      # flash[:error] = "No Item could be added."
    end  
    es.exhibited_items << er
    es.exhibited_items.last.move_to_top
    unless er.blank?
      redirect_to edit_page_url(:exhibit_id => es.page.exhibit, :id => es.page, :anchor => dom_id(er))
    else
      redirect_to edit_page_url(es.page.exhibit, es.page)
    end  
  end

  def update
    @exhibited_item = ExhibitedItem.find(params[:id])
    @exhibit = Exhibit.find(params[:exhibit_id])

    respond_to do |format|
      if @exhibited_item.update_attributes(params[:exhibited_item])
        flash[:notice] = 'Exhibited Item was successfully updated.'
        format.html { redirect_to edit_exhibit_url(:id => @exhibit, :anchor => dom_id(@exhibited_item)) }
        format.xml  { head :ok }
      else
        format.html { redirect_to edit_exhibit_url(@exhibit) }
        format.xml  { render :xml => @exhibited_item.errors.to_xml }
      end
    end
  end

  def destroy
    @exhibited_item = ExhibitedItem.find(params[:id])
    @exhibit = Exhibit.find(params[:exhibit_id])
    @exhibited_page = ExhibitedPage.find(params[:page_id])
    @exhibited_item.destroy

    respond_to do |format|
      flash[:notice] = 'Exhibited Item was successfully removed.'
      page = params[:page] || 1
      format.html { redirect_to edit_page_url(:exhibit_id => @exhibit, :id => @exhibited_page, :anchor => dom_id(@exhibited_item.section)) }
      format.xml  { head :ok }
    end
  end  
end
