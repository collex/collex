##########################################################################
# Copyright 2007 Applied Research in Patacriticism and the University of Virginia
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################

class ExhibitedSectionsController < ExhibitsBaseController
  
  in_place_edit_for_resource :exhibited_section, :title
  in_place_edit_for_resource :exhibited_section, :annotation

  def move_higher
    move_item(:move_higher, "Moved Exhibited Section Up.")
  end  
  def move_lower
    move_item(:move_lower, "Moved Exhibited Section Down.")
  end  
  def move_to_top
    move_item(:move_to_top, "Moved Exhibited Section to Top.")
  end  
  def move_to_bottom
    move_item(:move_to_bottom, "Moved Exhibited Section to Bottom.")
  end
  def move_item(command, notice)
    @exhibited_section = @exhibit.exhibited_pages.find(params[:page_id]).exhibited_sections.find(params[:id])
    @exhibited_section.__send__(command)
    logger.info("ExhibitedSection: #{command.to_s}: #{params[:id]}")
    flash[:notice] = notice
    redirect_to edit_exhibit_page_path(:id => params[:page_id], :exhibit_id => @exhibit, :anchor => dom_id(@exhibited_section))
  rescue Exception => e
    logger.info("Error: #{command} with id=#{params[:id]} failed with #{e}")
    flash[:error] = "There was an error moving your section."
    redirect_to edit_exhibit_page_path(:id => params[:page_id], :exhibit_id => @exhibit)
  end
  private :move_item  

  def create
    @exhibit = Exhibit.find(params[:exhibit_id])
    @exhibited_page = @exhibit.exhibited_pages.find(params[:page_id])
    respond_to do |format|
      if @exhibited_page.exhibited_sections << ExhibitedSection.new(:exhibit_section_type_id => params[:exhibit_section_type_id])
        @exhibited_page.exhibited_sections.last.move_to_top
        flash[:notice] = 'A new Exhibited Section was successfully added.'
        format.html { redirect_to edit_exhibit_page_path(:id => @exhibited_page, :exhibit_id => @exhibited_page.exhibit_id) }
        format.xml  { head :ok }
      else
        format.html do
          flash[:error] = "There was a problem creating a new Exibited Section."
          redirect_to edit_exhibit_page_path(:id => @exhibited_page, :exhibit_id => @exhibited_page.exhibit_id)
        end
        format.xml  { render :xml => @exhibited_section.errors.to_xml }
      end
    end
    
  end
  
  def update
    @exhibited_page = @exhibit.exhibited_pages.find(params[:page_id])
    @exhibited_section = @exhibited_page.exhibited_sections.find(params[:id])

    respond_to do |format|
      if @exhibited_section.update_attributes(params[:exhibited_section])
        flash[:notice] = 'Exhibited Section was successfully updated.'
        format.html { redirect_to edit_exhibit_page_path(:id => @exhibited_page, :exhibit_id => @exhibited_page.exhibit_id, :anchor => dom_id(@exhibited_section)) }
        format.xml  { head :ok }
      else
        format.html { redirect_to edit_exhibit_page_path(:id => @exhibited_page, :exhibit_id => @exhibited_page.exhibit_id) }
        format.xml  { render :xml => @exhibited_section.errors.to_xml }
      end
    end
  end
  
  def destroy
    @exhibited_page = @exhibit.exhibited_pages.find(params[:page_id])
    @exhibited_section = @exhibited_page.exhibited_sections.find(params[:id])
    @exhibited_section.destroy

    respond_to do |format|
      flash[:notice] = 'Exhibited Section was successfully removed.'
      format.html { redirect_to edit_exhibit_page_path(:id => @exhibited_page, :exhibit_id => @exhibited_page.exhibit_id) }
      format.xml  { head :ok }
    end
  end
end
