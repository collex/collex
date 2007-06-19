class ExhibitedPagesController < ExhibitsBaseController
  layout "nines"
  helper ExhibitsHelper
  before_filter :authorize_owner, :except => [:show]
  
  in_place_edit_for_resource :exhibited_page, :title
  in_place_edit_for_resource :exhibited_page, :annotation

  def move_higher
    move_item(:move_higher, "Moved Page Up.")
  end  
  def move_lower
    move_item(:move_lower, "Moved Page Down.")
  end  
  def move_to_top
    move_item(:move_to_top, "Moved Page to Top.")
  end  
  def move_to_bottom
    move_item(:move_to_bottom, "Moved Page to Bottom.")
  end
  def move_item(command, notice)
    @exhibited_page = @exhibit.exhibited_pages.find(params[:id])
    @exhibited_page.__send__(command)
    logger.info("ExhibitedPage: #{command.to_s}: #{params[:id]}")
    flash[:notice] = notice
    redirect_to edit_page_path(:id => @exhibited_page, :exhibit_id => @exhibit)
  rescue Exception => e
    logger.info("Error: #{command} with id=#{params[:id]} failed with #{e}")
    flash[:error] = "There was an error moving your page."
    redirect_to edit_page_path(:id => @exhibited_page, :exhibit_id => @exhibit)
  end
  private :move_item
  
  # Note @exhibit is populated in ExhibitsBaseController except for index
  def index
    @exhibit = Exhibit.find(params[:exhibit_id])
    @exhibited_pages = @exhibit.exhibited_pages
  end

  def show
    @exhibited_page = @exhibit.exhibited_pages.find(params[:id])
  end

  def edit
    @exhibited_page = @exhibit.exhibited_pages.find(params[:id])
    @licenses = License.find(:all)    
  end

  def new
  end
  
  # Note, just have one page type per exhibit right now, so grab the first
  def create
#     @exhibit = Exhibit.find(params[:exhibit_id])
    flash[:notice] = 'Page was successfully created.'
    page_type = @exhibit.valid_page_types.first
    if @page = @exhibit.pages.create({:exhibit_page_type_id => page_type.id})
      flash[:notice] = 'Page was successfully created.'
      redirect_to edit_page_path(:id => @page, :exhibit_id => @exhibit)
    else
      flash[:error] = 'There was an error creating the new page.'
      redirect_to edit_page_path(:id => params[:page_id], :exhibit_id => @exhibit)
    end
  end
  
  def destroy
    @exhibited_page = ExhibitedPage.find(params[:id])
    if(@exhibit.pages.count <= 1)
      flash[:error] = "This is your only page, so it can not be removed."
      redirect_to edit_page_path(@exhibit, @exhibited_page)
    else
      @exhibited_page.destroy
      flash[:notice] = "Your Page was deleted successfully."
      redirect_to edit_page_path(@exhibit, @exhibit.pages.first)
    end
  end
end
