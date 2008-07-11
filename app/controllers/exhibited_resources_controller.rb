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
    redirect_to edit_exhibit_page_url(es.page.exhibit, es.page)
  end

end
