class ExhibitedSectionsController < ApplicationController
  
  in_place_edit_for_resource :exhibited_section, :title
  in_place_edit_for_resource :exhibited_section, :annotation
  
  def create
    @exhibit = Exhibit.find(params[:exhibit_id])
    respond_to do |format|
      if @exhibit.exhibited_sections << ExhibitedSection.new(:exhibit_section_type_id => params[:exhibit_section_type_id])
        @exhibit.exhibited_sections.last.move_to_top
        flash[:notice] = 'A new Exhibited Section was successfully added.'
        format.html { redirect_to edit_exhibit_url(:id => @exhibit) }
        format.xml  { head :ok }
      else
        format.html do
          flash[:error] = "There was a problem creating a new Exibited Section."
          redirect_to edit_exhibit_url(@exhibit)
        end
        format.xml  { render :xml => @exhibited_section.errors.to_xml }
      end
    end
    
  end
  
  def update
    @exhibited_section = ExhibitedSection.find(params[:id])
    @exhibit = Exhibit.find(params[:exhibit_id])

    respond_to do |format|
      if @exhibited_section.update_attributes(params[:exhibited_section])
        flash[:notice] = 'Exhibited Section was successfully updated.'
        format.html { redirect_to edit_exhibit_url(:id => @exhibit, :anchor => dom_id(@exhibited_section)) }
        format.xml  { head :ok }
      else
        format.html { redirect_to edit_exhibit_url(@exhibit) }
        format.xml  { render :xml => @exhibited_section.errors.to_xml }
      end
    end
  end
  
  def destroy
    @exhibited_section = ExhibitedSection.find(params[:id])
    @exhibit = Exhibit.find(params[:exhibit_id])
    @exhibited_section.destroy

    respond_to do |format|
      flash[:notice] = 'Exhibited Section was successfully removed.'
      format.html { redirect_to edit_exhibit_url(@exhibit) }
      format.xml  { head :ok }
    end
  end
end
