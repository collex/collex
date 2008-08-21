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

class ExhibitsController < ExhibitsBaseController
  layout "collex"

#   if ENV['RAILS_ENV'] == 'production'
#     before_filter :coming_soon
#   end  

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
  
  def arrange
    @thumbnails = @exhibit.thumbnails << DEFAULT_THUMBNAIL_IMAGE_PATH
  end
  
  def sort
    logger.info("!!!!!!!!!!!!!!!! params dump: #{params.inspect}")
    page_order = params["sortable-pages"]
    
    # dump parm keys like "exhibited_section_" to get keys, then get the values, which are the resources in each section.
    logger.info("!!!!!!!!!!! params.keys: #{params.keys.class}")
    section_keys = params.keys.inject([]){|a, key| a << key if key =~ /exhibited_section_/; a }
    logger.info("!!!!!!!!!!! section keys: #{section_keys}")
    
    section_keys.each do |sk|
      resource_order = params[sk]
      logger.info("!!!!!!!!!!! sk: #{sk.split('_').last}")
      
      resource_order.each_with_index do |resource_id, k|
        r = ExhibitedItem.find(resource_id)
        r.position = k + 1
        r.exhibited_section_id = sk.split('_').last.to_i
        r.save
      end
    end
    
    #update the sections before the pages
    page_order.each do |page_id|
      section_order = params["exhibited_page_#{page_id}"] || []
      section_order.each_with_index do |section_id, j|
        s = ExhibitedSection.find(section_id)
        s.position = j + 1
        s.exhibited_page_id = page_id
        s.save
      end
    end
    
    page_order.each_with_index do |page_id, i|
      p = @exhibit.pages.find(page_id)
      p.position = i + 1
      p.save
    end
    render :nothing => true
  end
  
  def index
    @exhibits = params[:user_id] ? Exhibit.find_all_by_user_id(params[:user_id]) : Exhibit.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @exhibits.to_xml }
    end
  end
  
  def show
  end
  
  def collect
    @exhibit = Exhibit.find(params[:id])
    if @exhibit.index!
      flash[:notice] = 'Exhibit was successfully indexed.'
    else
      flash[:error] = 'There was a problem indexing your exhibit.'
    end
    redirect_to edit_exhibit_page_url(:exhibit_id => @exhibit, :id => @exhibit.pages.first.id)
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
      redirect_to edit_exhibit_page_url(:exhibit_id => @exhibit, :id => @exhibit.pages.first.id)
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

  def unpublish
    if @exhibit.publishable_by?(user_or_guest)
      @exhibit.unpublish!
      @exhibit.save!
      flash[:notice] = "#{@exhibit.title} has been successfully un-published."
    else
      flash[:error] = "You do not have persmission to un-publish that exhibit."
    end
    redirect_to :action => "index"
  end
  
  def update
    # @exhibit retrieved in authorize_owner
    page_id = params[:page_id]
    if @exhibit.update_attributes(params[:exhibit])
      flash[:notice] = 'Exhibit was successfully updated.'
      redirect_to edit_exhibit_page_url(:exhibit_id => @exhibit, :id => page_id)
    else
      render :action => "edit"
    end
  end
  
  def update_thumbnail
    if request.xhr?
      if @exhibit.update_attributes(params[:exhibit])
        render :nothing => true, :status => :ok
      else
        render :nothing => true, :status => 500
      end
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
