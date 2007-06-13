class ExhibitedPagesController < ExhibitsBaseController
  layout "nines"
  
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
  end

  def new
  end
end
