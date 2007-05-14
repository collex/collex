class ExhibitsController < ExhibitsBaseController
  layout "nines"
  prepend_before_filter :authorize, :only => [:create, :new, :edit, :update, :destroy]
  before_filter :authorize_owner, :only => [:edit, :update, :destroy]

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
    @exhibited_sections = @exhibit.exhibited_sections.find(:all, :page => {:current => params[:page]})
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
    @exhibited_sections = @exhibit.exhibited_sections.find(:all, :page => {:current => params[:page]})
    @licenses = License.find(:all)
  end

  def create
    @exhibit = Exhibit.new(params[:exhibit])
    respond_to do |format|
      if @exhibit.save
        flash[:notice] = 'Exhibit was successfully created.'
        format.html { redirect_to edit_exhibit_url(:id => @exhibit) }
        format.xml  { head :created, :location => exhibit_url(@exhibit) }
      else
        format.html do
          @licenses = License.find(:all)
          @exhibit_types = ExhibitType.find(:all)
          render :action => "new"
        end
        format.xml  { render :xml => @exhibit.errors.to_xml }
      end
    end
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
