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

class Admin::LicensesController < Admin::BaseController

  def index
    @license_pages, @licenses = paginate :licenses, :per_page => 10
  end

  def new
    @license = License.new
  end
  
  def create
    @license = License.new(params[:license])
    if @license.save
      flash[:notice] = 'License was successfully created.'
      redirect_to :action => 'index'
    else
      flash[:warning] = "License was not created."
      render :action => 'new'
    end
  end

  def edit
    @license = License.find(params[:id])
  end
  
  def update
    @license = License.find(params[:id])
    if @license.update_attributes(params[:license])
      flash[:notice] = 'License was successfully updated.'
    else
      flash[:warning] = "License was not updated."
    end  
    redirect_to :action => 'show', :id => @license
  end

  def show
    @license = License.find(params[:id])
  end
  
  def destroy
    License.destroy(params[:id])
    flash[:notice] = "License was successfully destroyed."
    redirect_to :action => 'index'
  end
end
