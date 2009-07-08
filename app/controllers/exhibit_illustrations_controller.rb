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

class ExhibitIllustrationsController < Admin::BaseController
  # DELETE /exhibit_illustrations/1
  # DELETE /exhibit_illustrations/1.xml
  def destroy
    @exhibit_illustration = ExhibitIllustration.find(params[:id])
    @exhibit_illustration.destroy

    respond_to do |format|
      format.html { redirect_to(exhibit_illustrations_url) }
      format.xml  { head :ok }
    end
  end
end
