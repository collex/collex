class ExhibitedSectionsController < ApplicationController
  # PUT /exhibited_sections/1
  # PUT /exhibited_sections/1.xml
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
  
  # DELETE /exhibited_sections/1
  # DELETE /exhibited_sections/1.xml
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
