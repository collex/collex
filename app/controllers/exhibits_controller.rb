##########################################################################
# Copyright 2007 Applied Research in Patacriticism
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

class ExhibitsController < ExhibitsBaseController
  layout "collex"

  if ENV['RAILS_ENV'] == 'production'
    before_filter :coming_soon
  end  

  uses_tiny_mce(:options => {
                  :browsers => "msie,gecko,opera",
                  :editor_selector => "tiny-mce",
                  :theme => "advanced", 
                  :theme_advanced_toolbar_location => "top",
                  :theme_advanced_toolbar_align => "left",
                  :theme_advanced_resizing => true,
                  :theme_advanced_buttons1 => "bold,italic,underline,separator,preview,separator,outdent,indent,unlink,link,separator,undo,redo,separator,cleanup,code,help",
                  :theme_advanced_buttons2 => "",
                  :theme_advanced_buttons3 => "",
                  :plugins => ["preview"],
                  :entity_encoding => "raw"
                },
                :only => [:new])
                
  in_place_edit_for_resource :exhibit, :title
  in_place_edit_for_resource :exhibit, :annotation
  
  def coming_soon
    render :template => "exhibits/coming_soon" and return unless (!username.nil?) and EXHIBIT_WHITE_LIST.include?(username)
  end
  private :coming_soon
  
  def index
    @exhibits = params[:user_id] ? Exhibit.find_all_by_user_id(params[:user_id]) : Exhibit.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @exhibits.to_xml }
    end
  end
  
  def show
  end


  def new
    @exhibit = Exhibit.new
    @exhibit.user = User.find_by_username(my_username)
    @exhibit_types = ExhibitType.find(:all)
  end

  def create
    @exhibit = Exhibit.new(params[:exhibit])
    if @exhibit.save
      flash[:notice] = 'Exhibit was successfully created.'
      page_type = @exhibit.valid_page_types.first
      @exhibit.pages.create({:exhibit_page_type_id => page_type.id})

      if page_type.section_types.size == 1
        @exhibit.pages.last.sections.create({:exhibit_section_type_id => page_type.section_types.first.id})
      end      
      redirect_to edit_page_url(:exhibit_id => @exhibit, :id => @exhibit.pages.first.id)
    else
      @exhibit_types = ExhibitType.find(:all)
      render :action => "new"
    end
  end
  
  def share
    if @exhibit.sharable_by?(user_or_guest)
      @exhibit.share!
      @exhibit.save!
      respond_to do |format|
        format.html do
          flash[:notice] = "#{@exhibit.title} has been successfully shared."
          redirect_to(:action => "index")
        end
        format.js do
          render :update do |page|
            page.replace_html 'exhibit-menu-share', :partial => 'unshare'
            page.insert_html :bottom, 'exhibit-menu-list', "<li id='exhibit-menu-publish'></li>"
            page.replace_html 'exhibit-menu-publish', :partial => 'publish'
          end
        end
      end
    else
      format.html do
        flash[:error] = "You do not have persmission to share that exhibit."
        redirect_to(:action => "index")
      end
    end
  end
  
  def unshare
    if @exhibit.unsharable_by?(user_or_guest)
      @exhibit.unshare!
      @exhibit.save!
      respond_to do |format|
        format.html do
          flash[:notice] = "#{@exhibit.title} has been successfully un-shared."
          redirect_to(:action => "index")
        end
        format.js do
          render :update do |page|
            page.replace_html 'exhibit-menu-share', :partial => 'share'
            page.remove 'exhibit-menu-publish'
          end
        end
      end
    else
      flash[:error] = "You do not have persmission to un-share that exhibit."
    end
  end

  def publish
    if @exhibit.publishable_by?(user_or_guest)
      @exhibit.publish!
      @exhibit.save!
      flash[:notice] = "#{@exhibit.title} has been successfully published."
    else
      flash[:error] = "You do not have persmission to publish that exhibit."
    end
    redirect_to :action => "index"
  end
  
  def update
    # @exhibit retrieved in authorize_owner
    page_id = params[:page_id]
    if @exhibit.update_attributes(params[:exhibit])
      flash[:notice] = 'Exhibit was successfully updated.'
      redirect_to edit_page_url(:exhibit_id => @exhibit, :id => page_id)
    else
      render :action => "edit"
    end
  end

  def destroy
    # @exhibit retrieved in authorize_owner
    @exhibit.destroy

    respond_to do |format|
      format.html { redirect_to exhibits_url }
      format.xml  { head :ok }
    end
  end
  
end
