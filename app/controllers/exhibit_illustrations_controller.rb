class ExhibitIllustrationsController < Admin::BaseController
#  # GET /exhibit_illustrations
#  # GET /exhibit_illustrations.xml
#  def index
#    @exhibit_illustrations = ExhibitIllustration.find(:all)
#
#    respond_to do |format|
#      format.html # index.html.erb
#      format.xml  { render :xml => @exhibit_illustrations }
#    end
#  end
#
#  # GET /exhibit_illustrations/1
#  # GET /exhibit_illustrations/1.xml
#  def show
#    @exhibit_illustration = ExhibitIllustration.find(params[:id])
#
#    respond_to do |format|
#      format.html # show.html.erb
#      format.xml  { render :xml => @exhibit_illustration }
#    end
#  end
#
#  # GET /exhibit_illustrations/new
#  # GET /exhibit_illustrations/new.xml
#  def new
#    @exhibit_illustration = ExhibitIllustration.new
#
#    respond_to do |format|
#      format.html # new.html.erb
#      format.xml  { render :xml => @exhibit_illustration }
#    end
#  end
#
#  # GET /exhibit_illustrations/1/edit
#  def edit
#    @exhibit_illustration = ExhibitIllustration.find(params[:id])
#  end
#
#  # POST /exhibit_illustrations
#  # POST /exhibit_illustrations.xml
#  def create
#    @exhibit_illustration = ExhibitIllustration.new(params[:exhibit_illustration])
#
#    respond_to do |format|
#      if @exhibit_illustration.save
#        flash[:notice] = 'ExhibitIllustration was successfully created.'
#        format.html { redirect_to(@exhibit_illustration) }
#        format.xml  { render :xml => @exhibit_illustration, :status => :created, :location => @exhibit_illustration }
#      else
#        format.html { render :action => "new" }
#        format.xml  { render :xml => @exhibit_illustration.errors, :status => :unprocessable_entity }
#      end
#    end
#  end
#
#  # PUT /exhibit_illustrations/1
#  # PUT /exhibit_illustrations/1.xml
#  def update
#    @exhibit_illustration = ExhibitIllustration.find(params[:id])
#
#    respond_to do |format|
#      if @exhibit_illustration.update_attributes(params[:exhibit_illustration])
#        flash[:notice] = 'ExhibitIllustration was successfully updated.'
#        format.html { redirect_to(@exhibit_illustration) }
#        format.xml  { head :ok }
#      else
#        format.html { render :action => "edit" }
#        format.xml  { render :xml => @exhibit_illustration.errors, :status => :unprocessable_entity }
#      end
#    end
#  end

  # DELETE /exhibit_illustrations/1
  # DELETE /exhibit_illustrations/1.xml
  def destroy
    @exhibit_illustration = ExhibitIllustration.find(params[:id])
    @exhibit_illustration.destroy

    respond_to do |format|
      format.html { redirect_to(exhibit_illustrations_url) }
      format.xml  { head :ok }
    end
  end
end
