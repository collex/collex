class ExhibitedTextsController < ExhibitedItemsController
  in_place_edit_for_resource :exhibited_texts, :annotation
  
  def create
    @exhibited_text = ExhibitedText.new(params[:exhibited_text])
    exhibited_section_id = params[:exhibited_section_id].to_i
    es = ExhibitedSection.find(exhibited_section_id)
    et = ExhibitedText.new
    flash[:notice] = "The Text area was successfully created."
    es.items << et
    es.items.last.move_to_top
    unless et.blank?
      redirect_to edit_page_url(:exhibit_id => es.page.exhibit, :id => es.page, :anchor => dom_id(et))
    else
      redirect_to edit_page_url(es.page.exhibit, es.page)
    end  
  end
end