##########################################################################
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################

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