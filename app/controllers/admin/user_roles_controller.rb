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
#    @users = User.all(:order => 'username')
#    @users = User.paginate(:page => params[:page], :per_page => 30, :order => 'username')
		page = params[:page]
		page = 'A' if page == nil
		lower_case_page = page.downcase()
		all_users = User.all(:order => 'username')
		@users = []
		all_users.each {|user|
			if user.username[0] == page[0] || user.username[0] == lower_case_page[0] ||
				user.username[0] < 'A' || user.username[0] > 'z' || (user.username[0] > 'Z' && user.username[0] < 'a')
				@users.push(user)
			end
		}
		@admins = User.get_administrators()
  end

#  def list
#    @users = User.paginate(:page => params[:page], :per_page => 30, :order => 'username')
#  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
    @roles = Role.all
    @page = params[:page]
    @page = '1' if !@page || @page.length == 0
  end

  def update
    @user = User.find(params[:id])
    @roles = Role.all
    roles_hash = {}
    @roles.each { |role| roles_hash["user_role_#{role.name}"] = role }
    user_roles = roles_hash.reject { |k,v| !params.has_key? k }.values
    @user.roles = user_roles
    
    if @user.save
      flash[:notice] = 'User was successfully updated.'
      redirect_to :action => 'index', :page => params[:page]
    else
      render :action => 'index', :page => params[:page]
    end
  end

  def destroy
    User.find(params[:id]).destroy
    redirect_to :action => 'index', :page => params[:page]
  end
end
