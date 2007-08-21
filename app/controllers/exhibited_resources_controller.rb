class ExhibitedResourcesController < ExhibitedItemsController
  
  in_place_edit_for_resource :exhibited_resource, :annotation

  def create
    unless params[:new_resource].blank?
      uri = params[:new_resource].match('thumbnail_').post_match
      interpretation = Interpretation.find_by_user_id_and_object_uri(user.id, uri)
      resource = SolrResource.find_by_uri(uri)
      
      annotation = case
        when interpretation.nil?, interpretation.annotation.strip.blank?
          ""
        else
          interpretation.annotation
        end
      
      annotation = "(#{resource.date_label_or_date}) " + annotation unless resource.nil? or resource.date_label_or_date.blank? 
      annotation = "<em>#{resource.title}</em> " + annotation unless resource.nil? or resource.title.blank? 
      annotation = nil if annotation.strip.blank?
      
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
