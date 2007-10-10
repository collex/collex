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

class Admin::UserRolesController < Admin::BaseController
  def index
    list
    render :action => 'list'
  end

  def list
    @user_pages, @users = paginate :users, :per_page => 10
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
    @roles = Role.find :all
  end

  def update
    @user = User.find(params[:id])
    @roles = Role.find :all
    roles_hash = {}
    @roles.each { |role| roles_hash["user_role_#{role.name}"] = role }
    user_roles = roles_hash.reject { |k,v| !params.has_key? k }.values
    @user.roles = user_roles
    
    if @user.save
      flash[:notice] = 'User was successfully updated.'
      redirect_to :action => 'edit', :id => @user
    else
      render :action => 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
