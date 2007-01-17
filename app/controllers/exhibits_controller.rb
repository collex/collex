class ExhibitsController < ApplicationController
  layout "nines"

  # GET /exhibits
  # GET /exhibits.xml
  def index
    @exhibits = Exhibit.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @exhibits.to_xml }
    end
  end

  # GET /exhibits/1
  # GET /exhibits/1.xml
  def show
    @exhibit = Exhibit.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @exhibit.to_xml }
    end
  end

  # GET /exhibits/new
  def new
    @exhibit = Exhibit.new
  end

  # GET /exhibits/1;edit
  def edit
    @exhibit = Exhibit.find(params[:id])
  end

  # POST /exhibits
  # POST /exhibits.xml
  def create
    @exhibit = Exhibit.new(params[:exhibit])

    respond_to do |format|
      if @exhibit.save
        flash[:notice] = 'Exhibit was successfully created.'
        format.html { redirect_to exhibit_url(@exhibit) }
        format.xml  { head :created, :location => exhibit_url(@exhibit) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @exhibit.errors.to_xml }
      end
    end
  end

  # PUT /exhibits/1
  # PUT /exhibits/1.xml
  def update
    @exhibit = Exhibit.find(params[:id])

    respond_to do |format|
      if @exhibit.update_attributes(params[:exhibit])
        flash[:notice] = 'Exhibit was successfully updated.'
        format.html { redirect_to exhibit_url(@exhibit) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @exhibit.errors.to_xml }
      end
    end
  end

  # DELETE /exhibits/1
  # DELETE /exhibits/1.xml
  def destroy
    @exhibit = Exhibit.find(params[:id])
    @exhibit.destroy

    respond_to do |format|
      format.html { redirect_to exhibits_url }
      format.xml  { head :ok }
    end
  end
end
