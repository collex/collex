class ExhibitObjectsController < Admin::BaseController
#  # GET /exhibit_objects
#  # GET /exhibit_objects.xml
#  def index
#    @exhibit_objects = ExhibitObject.find(:all)
#
#    respond_to do |format|
#      format.html # index.html.erb
#      format.xml  { render :xml => @exhibit_objects }
#    end
#  end
#
#  # GET /exhibit_objects/1
#  # GET /exhibit_objects/1.xml
#  def show
#    @exhibit_object = ExhibitObject.find(params[:id])
#
#    respond_to do |format|
#      format.html # show.html.erb
#      format.xml  { render :xml => @exhibit_object }
#    end
#  end
#
#  # GET /exhibit_objects/new
#  # GET /exhibit_objects/new.xml
#  def new
#    @exhibit_object = ExhibitObject.new
#
#    respond_to do |format|
#      format.html # new.html.erb
#      format.xml  { render :xml => @exhibit_object }
#    end
#  end
#
#  # GET /exhibit_objects/1/edit
#  def edit
#    @exhibit_object = ExhibitObject.find(params[:id])
#  end
#
#  # POST /exhibit_objects
#  # POST /exhibit_objects.xml
#  def create
#    @exhibit_object = ExhibitObject.new(params[:exhibit_object])
#
#    respond_to do |format|
#      if @exhibit_object.save
#        flash[:notice] = 'ExhibitObject was successfully created.'
#        format.html { redirect_to(@exhibit_object) }
#        format.xml  { render :xml => @exhibit_object, :status => :created, :location => @exhibit_object }
#      else
#        format.html { render :action => "new" }
#        format.xml  { render :xml => @exhibit_object.errors, :status => :unprocessable_entity }
#      end
#    end
#  end
#
#  # PUT /exhibit_objects/1
#  # PUT /exhibit_objects/1.xml
#  def update
#    @exhibit_object = ExhibitObject.find(params[:id])
#
#    respond_to do |format|
#      if @exhibit_object.update_attributes(params[:exhibit_object])
#        flash[:notice] = 'ExhibitObject was successfully updated.'
#        format.html { redirect_to(@exhibit_object) }
#        format.xml  { head :ok }
#      else
#        format.html { render :action => "edit" }
#        format.xml  { render :xml => @exhibit_object.errors, :status => :unprocessable_entity }
#      end
#    end
#  end
#
#  # DELETE /exhibit_objects/1
#  # DELETE /exhibit_objects/1.xml
#  def destroy
#    @exhibit_object = ExhibitObject.find(params[:id])
#    @exhibit_object.destroy
#
#    respond_to do |format|
#      format.html { redirect_to(exhibit_objects_url) }
#      format.xml  { head :ok }
#    end
#  end
end
