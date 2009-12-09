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

class ExhibitsController < ApplicationController
  layout 'nines'
  before_filter :init_view_options

  private
  def init_view_options
    @use_tabs = true
    @use_signin= true
    @site_section = :exhibits
    @uses_yui = true
    return true
  end
  public

  def list
    @exhibits = Exhibit.get_all_published()
  end
  
  def view
    # First see if we were given an alias
    id = params[:id]
		if id == nil
			redirect_to :action => 'list'
			return
		end
    @exhibit = Exhibit.find_by_visible_url(id)
    if @exhibit == nil
      if id.to_i > 0
        @exhibit = Exhibit.find(id)
      else
        redirect_to :action => 'list'
        return
      end
    end

    @site_section = :view_exhibit
    @page = -10
    if params[:page]
      @page = params[:page].to_i
    end
    if @page != -1 && (@page < 1 || @page > @exhibit.exhibit_pages.length)
      @page = 1
    end

		# Be sure the current user is authorized to see this exhibit
		if @exhibit.is_published == 0	# allow published exhibits
			user = session[:user]
			if user == nil	# if the user isn't logged in, then disallow.
				redirect_to :action => 'list'
				return
			end
			if !is_admin?
				user = User.find_by_username(user[:username])
				if user.id != @exhibit.user_id
					redirect_to :action => 'list'
					return
				end
			end
		end
    #render :layout => 'exhibits_view'
  end

	def print_exhibit
    @site_section = :print_exhibit
		@exhibit = Exhibit.find(params[:id])
	end

  ##################################################################################
  # GET /exhibits
  # GET /exhibits.xml
#  def index
#    @exhibits = Exhibit.find(:all)
#
#    respond_to do |format|
#      format.html # index.html.erb
#      format.xml  { render :xml => @exhibits }
#    end
#  end
#
#  # GET /exhibits/1
#  # GET /exhibits/1.xml
#  def show
#    @exhibit = Exhibit.find(params[:id])
#
#    respond_to do |format|
#      format.html # show.html.erb
#      format.xml  { render :xml => @exhibit }
#    end
#  end
#
#  # GET /exhibits/new
#  # GET /exhibits/new.xml
#  def new
#    @exhibit = Exhibit.new
#
#    respond_to do |format|
#      format.html # new.html.erb
#      format.xml  { render :xml => @exhibit }
#    end
#  end
#
#  # GET /exhibits/1/edit
#  def edit
#    @exhibit = Exhibit.find(params[:id])
#  end
#
#  # POST /exhibits
#  # POST /exhibits.xml
#  def create
#    @exhibit = Exhibit.new(params[:exhibit])
#
#    respond_to do |format|
#      if @exhibit.save
#        flash[:notice] = 'Exhibit was successfully created.'
#        format.html { redirect_to(@exhibit) }
#        format.xml  { render :xml => @exhibit, :status => :created, :location => @exhibit }
#      else
#        format.html { render :action => "new" }
#        format.xml  { render :xml => @exhibit.errors, :status => :unprocessable_entity }
#      end
#    end
#  end
#
#  # PUT /exhibits/1
#  # PUT /exhibits/1.xml
#  def update
#    @exhibit = Exhibit.find(params[:id])
#
#    respond_to do |format|
#      if @exhibit.update_attributes(params[:exhibit])
#        flash[:notice] = 'Exhibit was successfully updated.'
#        format.html { redirect_to(@exhibit) }
#        format.xml  { head :ok }
#      else
#        format.html { render :action => "edit" }
#        format.xml  { render :xml => @exhibit.errors, :status => :unprocessable_entity }
#      end
#    end
#  end
#
  # DELETE /exhibits/1
  # DELETE /exhibits/1.xml
  def destroy
    @exhibit = Exhibit.find(params[:id])
    @exhibit.destroy

    respond_to do |format|
      format.html { redirect_to(exhibits_url) }
      format.xml  { head :ok }
    end
  end
end
