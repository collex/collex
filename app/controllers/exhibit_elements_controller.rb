class ExhibitElementsController < Admin::BaseController
  # GET /exhibit_elements
  # GET /exhibit_elements.xml
  def index
    @exhibit_elements = ExhibitElement.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @exhibit_elements }
    end
  end

#  # GET /exhibit_elements/1
#  # GET /exhibit_elements/1.xml
#  def show
#    @exhibit_element = ExhibitElement.find(params[:id])
#
#    respond_to do |format|
#      format.html # show.html.erb
#      format.xml  { render :xml => @exhibit_element }
#    end
#  end

#  # GET /exhibit_elements/new
#  # GET /exhibit_elements/new.xml
#  def new
#    @exhibit_element = ExhibitElement.new
#
#    respond_to do |format|
#      format.html # new.html.erb
#      format.xml  { render :xml => @exhibit_element }
#    end
#  end

  # GET /exhibit_elements/1/edit
  def edit
    @exhibit_element = ExhibitElement.find(params[:id])
  end

#  # POST /exhibit_elements
#  # POST /exhibit_elements.xml
#  def create
#    @exhibit_element = ExhibitElement.new(params[:exhibit_element])
#
#    respond_to do |format|
#      if @exhibit_element.save
#        flash[:notice] = 'ExhibitElement was successfully created.'
#        format.html { redirect_to(@exhibit_element) }
#        format.xml  { render :xml => @exhibit_element, :status => :created, :location => @exhibit_element }
#      else
#        format.html { render :action => "new" }
#        format.xml  { render :xml => @exhibit_element.errors, :status => :unprocessable_entity }
#      end
#    end
#  end

  # PUT /exhibit_elements/1
  # PUT /exhibit_elements/1.xml
  def update
    @exhibit_element = ExhibitElement.find(params[:id])

    respond_to do |format|
      if @exhibit_element.update_attributes(params[:exhibit_element])
        flash[:notice] = 'ExhibitElement was successfully updated.'
        format.html { redirect_to(@exhibit_element) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @exhibit_element.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /exhibit_elements/1
  # DELETE /exhibit_elements/1.xml
  def destroy
    @exhibit_element = ExhibitElement.find(params[:id])
    @exhibit_element.destroy

    respond_to do |format|
      format.html { redirect_to(exhibit_elements_url) }
      format.xml  { head :ok }
    end
  end
end
