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
    @exhibited_user_resource.annotation = params[:exhibited_user_resource][:annotation]
    @exhibited_user_resource.save
    
    @exhibited_user_resource.properties.build(:name => "title", :value => params[:exhibited_user_resource][:title])
    @exhibited_user_resource.properties.build(:name => "date_label", :value => params[:exhibited_user_resource][:date_label])
    @exhibited_user_resource.properties.build(:name => "url", 
      :value => params[:exhibited_user_resource][:url]) unless params[:exhibited_user_resource][:url].blank?
    @exhibited_user_resource.properties.build(:name => "pubPlace", 
      :value => params[:exhibited_user_resource][:pubPlace]) unless params[:exhibited_user_resource][:pubPlace].blank?
    @exhibited_user_resource.properties.build(:name => "role_AUT", 
      :value => params[:exhibited_user_resource][:role_AUT]) unless params[:exhibited_user_resource][:role_AUT].blank?
    @exhibited_user_resource.properties.build(:name => "role_EDT", 
      :value => params[:exhibited_user_resource][:role_EDT]) unless params[:exhibited_user_resource][:role_EDT].blank?
    @exhibited_user_resource.properties.build(:name => "role_PBL", 
      :value => params[:exhibited_user_resource][:role_PBL]) unless params[:exhibited_user_resource][:role_PBL].blank?
    @exhibited_user_resource.properties.build(:name => "role_PBL", 
      :value => params[:exhibited_user_resource][:role_PBL]) unless params[:exhibited_user_resource][:role_PBL].blank?
    
    @exhibited_user_resource.save
    render :inline => "<%= @exhibited_user_resource.inspect %> <%= @exhibited_user_resource.properties.inspect %> "
  end
  
  def update
    
  end
  
  private
  def get_ancestors
    @exhibited_section = ExhibitedSection.find(params[:section_id])
    @exhibited_page = @exhibited_section.exhibited_page
    @exhibit = @exhibited_page.exhibit
  end
end
