class ExhibitsController < ExhibitsBaseController
  layout "nines"

  if ENV['RAILS_ENV'] == 'production'
    before_filter :coming_soon
  end  

  in_place_edit_for_resource :exhibit, :title
  in_place_edit_for_resource :exhibit, :annotation
  
  def coming_soon
    render :template => "exhibits/coming_soon" and return
  end
  private :coming_soon
  
  def index
    @exhibits = Exhibit.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @exhibits.to_xml }
    end
  end

  def show
    @exhibit = Exhibit.find(params[:id])
    @exhibited_pages = @exhibit.exhibited_pages
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @exhibit.to_xml }
    end
  rescue ActiveRecord::RecordNotFound
    flash[:warning] = "That Exhibit could not be found."
    redirect_to :action => "index"
  end

  def new
    @exhibit = Exhibit.new
    #TODO remove all this hard-coded data
    @exhibit.user = User.find_by_username(my_username)
    @exhibit.license_id = 1
    @exhibit.exhibit_type_id = 2
    @licenses = License.find(:all)
    @exhibit_types = ExhibitType.find(:all)
  end

  def edit
    # @exhibit retrieved in authorize_owner
#     @exhibited_sections = @exhibit.exhibited_sections.find(:all, :page => {:current => params[:page]})
    @exhibited_pages = @exhibit.exhibited_pages.find(:all, :page => {:current => params[:page]})
    @licenses = License.find(:all)
  end

  def create
    @exhibit = Exhibit.new(params[:exhibit])
    if @exhibit.save
      flash[:notice] = 'Exhibit was successfully created.'
      page_type = @exhibit.valid_page_types.first
      @exhibit.pages.create({:exhibit_page_type_id => page_type.id})
      redirect_to edit_page_url(:exhibit_id => @exhibit, :id => @exhibit.pages.first.id)
    else
      @licenses = License.find(:all)
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
    unless params[:new_resource].blank?
      uri = params[:new_resource].match('thumbnail_').post_match
      unless @exhibit.uris.include?(uri)
        exhibited_section_id = params[:exhibited_section_id].to_i
        es = @exhibit.exhibited_sections.find(exhibited_section_id)
        er = ExhibitedResource.new(:uri => uri)
        es.exhibited_resources << er
        es.exhibited_resources.last.move_to_top
        @exhibit.save
      else
        flash[:error] = "You already have that object in your collection."
      end
    end
    respond_to do |format|
      page = params[:page] || 1
      if @exhibit.update_attributes(params[:exhibit])
        flash[:notice] = 'Exhibit was successfully updated.'
        format.html do
          unless er.blank?
            redirect_to edit_exhibit_url(:id => @exhibit, :anchor => dom_id(er), :page => page)
          else
            redirect_to edit_exhibit_url(:id => @exhibit, :page => page)
          end
        end
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @exhibit.errors.to_xml }
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
