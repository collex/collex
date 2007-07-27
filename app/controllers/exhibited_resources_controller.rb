class ExhibitedResourcesController < ExhibitedItemsController
  
  in_place_edit_for_resource :exhibited_resource, :annotation

  def create
    @exhibited_resource = ExhibitedResource.new(params[:exhibited_resource])

    unless params[:new_resource].blank?
      uri = params[:new_resource].match('thumbnail_').post_match
      exhibited_section_id = params[:exhibited_section_id].to_i
      es = ExhibitedSection.find(exhibited_section_id)
      er = ExhibitedResource.new(:uri => uri)
      es.exhibited_resources << er
      flash[:error] = "You now have a duplicate of that object in your collection." if es.page.exhibit.uris.include?(uri)
      flash[:notice] = "The Resource was successfully added."
    else
      flash[:error] = "Resource was not added."
    end
    unless er.blank?
      redirect_to edit_page_url(:exhibit_id => es.page.exhibit, :id => es.page, :anchor => dom_id(er))
    else
      redirect_to edit_page_url(es.page.exhibit, es.page)
    end  
  end

end
