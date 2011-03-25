##########################################################################
# Copyright 2009 Applied Research in Patacriticism and the University of Virginia
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

class ExhibitElementsController < Admin::BaseController
  # GET /exhibit_elements
  # GET /exhibit_elements.xml
  def index
    @exhibit_elements = ExhibitElement.all()

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @exhibit_elements }
    end
  end

  # GET /exhibit_elements/1/edit
  def edit
    @exhibit_element = ExhibitElement.find(params[:id])
  end

  # PUT /exhibit_elements/1
  # PUT /exhibit_elements/1.xml
  def update
    @exhibit_element = ExhibitElement.find(params[:id])

    respond_to do |format|
      if @exhibit_element.update_attributes(params[:exhibit_element])
        flash[:notice] = 'ExhibitElement was successfully updated.'
        format.html { redirect_to(@exhibit_element) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @exhibit_element.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /exhibit_elements/1
  # DELETE /exhibit_elements/1.xml
  def destroy
    @exhibit_element = ExhibitElement.find(params[:id])
    @exhibit_element.destroy

    respond_to do |format|
      format.html { redirect_to(exhibit_elements_url) }
      format.xml  { head :ok }
    end
  end
end
