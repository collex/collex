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

class ExhibitsBaseController < ApplicationController
  prepend_before_filter :authorize, :except => [:index, :show, :uri, :intro]
  before_filter :authorize_owner, :except => [:create, :new, :index, :show, :intro]
  before_filter :authorize_viewer, :only => [:show]
  
  private
    # The permalink for an Exhibit is based on the URI generated at index time. 
    # If that URI is passed as the id, then the +Exhibit+ is found by the uri.
    def authorize_owner
      id = params[:exhibit_id] || params[:id]
      @exhibit = id.include?("-") ? Exhibit.find_by_uri(id) : Exhibit.find(id)
      unless @exhibit.updatable_by?(user_or_guest)
        logger.info("#{user_or_guest.username} with roles #{user_or_guest.role_names.join(', ')} may not edit #{@exhibit.title} (id=#{@exhibit.id})")
        if user
          flash[:warning] = "You do not have permission to edit that Exhibit!"
          redirect_to(exhibits_path) and return false
        else
          flash[:warning] = "You do not have permission to edit that Exhibit. Perhaps your session timed out. You may login below."
          redirect_to(:controller => "login", :action => "login") and return false
        end
      end
    rescue ActiveRecord::RecordNotFound
      logger.info("Exhibit with id #{id} not found.")
      flash[:warning] = "That Exhibit could not be found."
      redirect_to exhibits_path
    end
    
    def authorize_viewer
      id = params[:exhibit_id] || params[:id]
      @exhibit = id.include?("-") ? Exhibit.find_by_uri(id) : Exhibit.find(id)
      unless @exhibit.viewable_by?(user_or_guest)
        logger.info("#{user_or_guest.username} is not owner of #{@exhibit.title} (id=#{@exhibit.id})")
        flash[:warning] = "That exhibit has not been shared."
        redirect_to(exhibits_path) and return false
      end
    rescue ActiveRecord::RecordNotFound
      logger.info("Exhibit with id #{id} not found.")
      flash[:warning] = "That Exhibit could not be found."
      redirect_to exhibits_path
    end
end