class ExhibitSectionsController < ApplicationController
  # GET /exhibit_sections
  # GET /exhibit_sections.xml
  def index
    @exhibit_sections = ExhibitSection.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @exhibit_sections }
    end
  end

  # GET /exhibit_sections/1
  # GET /exhibit_sections/1.xml
  def show
    @exhibit_section = ExhibitSection.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @exhibit_section }
    end
  end

  # GET /exhibit_sections/new
  # GET /exhibit_sections/new.xml
  def new
    @exhibit_section = ExhibitSection.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @exhibit_section }
    end
  end

  # GET /exhibit_sections/1/edit
  def edit
    @exhibit_section = ExhibitSection.find(params[:id])
  end

  # POST /exhibit_sections
  # POST /exhibit_sections.xml
  def create
    @exhibit_section = ExhibitSection.new(params[:exhibit_section])

    respond_to do |format|
      if @exhibit_section.save
        flash[:notice] = 'ExhibitSection was successfully created.'
        format.html { redirect_to(@exhibit_section) }
        format.xml  { render :xml => @exhibit_section, :status => :created, :location => @exhibit_section }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @exhibit_section.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /exhibit_sections/1
  # PUT /exhibit_sections/1.xml
  def update
    @exhibit_section = ExhibitSection.find(params[:id])

    respond_to do |format|
      if @exhibit_section.update_attributes(params[:exhibit_section])
        flash[:notice] = 'ExhibitSection was successfully updated.'
        format.html { redirect_to(@exhibit_section) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @exhibit_section.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /exhibit_sections/1
  # DELETE /exhibit_sections/1.xml
  def destroy
    @exhibit_section = ExhibitSection.find(params[:id])
    @exhibit_section.destroy

    respond_to do |format|
      format.html { redirect_to(exhibit_sections_url) }
      format.xml  { head :ok }
    end
  end
end
