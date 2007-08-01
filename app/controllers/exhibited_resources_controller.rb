class ExhibitedResourcesController < ExhibitedItemsController
  
  in_place_edit_for_resource :exhibited_resource, :annotation

  def create
    @exhibited_resource = ExhibitedResource.new(params[:exhibited_resource])

    unless params[:new_resource].blank?
      uri = params[:new_resource].match('thumbnail_').post_match
      interpretation = Interpretation.find_by_user_id_and_object_uri(user.id, uri)
      
      annotation = case
        when interpretation.nil?, interpretation.annotation.strip.blank?
          nil
        else
          interpretation.annotation
        end
      
      exhibited_section_id = params[:exhibited_section_id].to_i
      es = ExhibitedSection.find(exhibited_section_id)
      er = ExhibitedResource.new(:uri => uri, :annotation => annotation)
      es.exhibited_resources << er
      es.exhibited_resources.last.move_to_top
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
