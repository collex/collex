##########################################################################
# Copyright 2008 Applied Research in Patacriticism and the University of Virginia
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

class ExhibitedUserResourcesController < ExhibitedItemsController
  layout "collex"
  
  before_filter :authorize_owner
  
  #in_place_edit_for_resource :exhibited_user_resource, :annotation
  
  def new
    get_ancestors
    @exhibited_user_resource = @exhibited_section.user_resources.build
  end  

  def edit
    get_ancestors
    @exhibited_user_resource = ExhibitedUserResource.find(params[:id])
  end
  
  def create
    get_ancestors
    @exhibited_user_resource = @exhibited_section.user_resources.build

    common_assignments

    if @exhibited_user_resource.save
      flash[:notice] = "Successfully created new resource #{@exhibited_user_resource.title}"
      redirect_to edit_exhibit_page_section_user_resource_path(@exhibit, @exhibited_page, @exhibited_section, @exhibited_user_resource)
    else
      render :action => "new"
    end
  end
  
  # Since we're using +ExhibitedProperties+, we just clear out the old objects before making new assignments.
  # Rails wants to save the associations--or ignore them depending on how they are assigned--even if the parent
  # isn't saved, so this has been hacked a bit to work.
  def update
    get_ancestors
    @exhibited_user_resource = ExhibitedUserResource.new

    @exhibited_user_resource.properties.clear
    common_assignments

    if @exhibited_user_resource.valid?
      eur = ExhibitedUserResource.find(params[:id])
      eur.properties.clear
      @exhibited_user_resource.properties.each {|prop| eur.properties << prop}
      eur.annotation = @exhibited_user_resource.annotation
      eur.save
      @exhibited_user_resource = eur
      flash[:notice] = "Successfully updated new resource #{@exhibited_user_resource.title}"
      redirect_to edit_exhibit_page_section_user_resource_path(@exhibit, @exhibited_page, @exhibited_section, @exhibited_user_resource)
    else
      @exhibited_user_resource.id = params[:id]
      render :action => "edit"
    end
  end
  
  private
  def common_assignments
    @exhibited_user_resource.annotation = params[:exhibited_user_resource][:annotation]

    @exhibited_user_resource.properties << ExhibitedProperty.new(:name => "title", :value => params[:exhibited_user_resource][:title])
    @exhibited_user_resource.properties << ExhibitedProperty.new(:name => "date_label",:value => params[:exhibited_user_resource][:date_label])

    @exhibited_user_resource.properties << ExhibitedProperty.new(:name => "url", 
      :value => params[:exhibited_user_resource][:url]) unless params[:exhibited_user_resource][:url].blank?

    @exhibited_user_resource.properties << ExhibitedProperty.new(:name => "role_CTY", 
      :value => params[:exhibited_user_resource][:role_CTY]) unless params[:exhibited_user_resource][:role_CTY].blank?

    params[:exhibited_user_resource][:role_AUT].each do |aut|
      @exhibited_user_resource.properties << ExhibitedProperty.new(:name => "role_AUT", :value => aut)
    end unless params[:exhibited_user_resource][:role_AUT].blank? 
    
    params[:exhibited_user_resource][:role_EDT].each do |edt|
      @exhibited_user_resource.properties << ExhibitedProperty.new(:name => "role_EDT", :value => edt)
    end unless params[:exhibited_user_resource][:role_EDT].blank?
    
    params[:exhibited_user_resource][:role_TRL].each do |trl|
      @exhibited_user_resource.properties << ExhibitedProperty.new(:name => "role_TRL", :value => trl)
    end unless params[:exhibited_user_resource][:role_TRL].blank?

    @exhibited_user_resource.properties << ExhibitedProperty.new(:name => "role_PBL", 
      :value => params[:exhibited_user_resource][:role_PBL]) unless params[:exhibited_user_resource][:role_PBL].blank?
  end
  def get_ancestors
    @exhibited_section = ExhibitedSection.find(params[:section_id])
    @exhibited_page = @exhibited_section.exhibited_page
    @exhibit = @exhibited_page.exhibit
  end
end
