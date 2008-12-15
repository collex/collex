class ExhibitPagesController < Admin::BaseController
#  # GET /exhibit_pages
#  # GET /exhibit_pages.xml
#  def index
#    @exhibit_pages = ExhibitPage.find(:all)
#
#    respond_to do |format|
#      format.html # index.html.erb
#      format.xml  { render :xml => @exhibit_pages }
#    end
#  end
#
#  # GET /exhibit_pages/1
#  # GET /exhibit_pages/1.xml
#  def show
#    @exhibit_page = ExhibitPage.find(params[:id])
#
#    respond_to do |format|
#      format.html # show.html.erb
#      format.xml  { render :xml => @exhibit_page }
#    end
#  end
#
#  # GET /exhibit_pages/new
#  # GET /exhibit_pages/new.xml
#  def new
#    @exhibit_page = ExhibitPage.new
#
#    respond_to do |format|
#      format.html # new.html.erb
#      format.xml  { render :xml => @exhibit_page }
#    end
#  end
#
#  # GET /exhibit_pages/1/edit
#  def edit
#    @exhibit_page = ExhibitPage.find(params[:id])
#  end
#
#  # POST /exhibit_pages
#  # POST /exhibit_pages.xml
#  def create
#    @exhibit_page = ExhibitPage.new(params[:exhibit_page])
#
#    respond_to do |format|
#      if @exhibit_page.save
#        flash[:notice] = 'ExhibitPage was successfully created.'
#        format.html { redirect_to(@exhibit_page) }
#        format.xml  { render :xml => @exhibit_page, :status => :created, :location => @exhibit_page }
#      else
#        format.html { render :action => "new" }
#        format.xml  { render :xml => @exhibit_page.errors, :status => :unprocessable_entity }
#      end
#    end
#  end
#
#  # PUT /exhibit_pages/1
#  # PUT /exhibit_pages/1.xml
#  def update
#    @exhibit_page = ExhibitPage.find(params[:id])
#
#    respond_to do |format|
#      if @exhibit_page.update_attributes(params[:exhibit_page])
#        flash[:notice] = 'ExhibitPage was successfully updated.'
#        format.html { redirect_to(@exhibit_page) }
#        format.xml  { head :ok }
#      else
#        format.html { render :action => "edit" }
#        format.xml  { render :xml => @exhibit_page.errors, :status => :unprocessable_entity }
#      end
#    end
#  end

  # DELETE /exhibit_pages/1
  # DELETE /exhibit_pages/1.xml
  def destroy
    @exhibit_page = ExhibitPage.find(params[:id])
    @exhibit_page.destroy

    respond_to do |format|
      format.html { redirect_to(exhibit_pages_url) }
      format.xml  { head :ok }
    end
  end
end
