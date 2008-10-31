class ExhibitsController < ApplicationController
  layout 'collex_tabs'
  before_filter :init_view_options

  private
  def init_view_options
    @use_tabs = true
    @use_signin= true
    @site_section = :exhibits
    return true
  end
  public

  def list
    @exhibits = Exhibit.find(:all, :conditions => [ 'is_published = 1'])
  end
  
  def view
    id = params[:id]
    @exhibit = Exhibit.find(id)
    if params[:page]
      @page = params[:page].to_i
     else
      @page = 1
     end
    render :layout => 'exhibits_view'
  end

  ##################################################################################
  # GET /exhibits
  # GET /exhibits.xml
  def index
    @exhibits = Exhibit.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @exhibits }
    end
  end

  # GET /exhibits/1
  # GET /exhibits/1.xml
  def show
    @exhibit = Exhibit.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @exhibit }
    end
  end

  # GET /exhibits/new
  # GET /exhibits/new.xml
  def new
    @exhibit = Exhibit.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @exhibit }
    end
  end

  # GET /exhibits/1/edit
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
        format.html { redirect_to(@exhibit) }
        format.xml  { render :xml => @exhibit, :status => :created, :location => @exhibit }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @exhibit.errors, :status => :unprocessable_entity }
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
        format.html { redirect_to(@exhibit) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @exhibit.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /exhibits/1
  # DELETE /exhibits/1.xml
  def destroy
    @exhibit = Exhibit.find(params[:id])
    @exhibit.destroy

    respond_to do |format|
      format.html { redirect_to(exhibits_url) }
      format.xml  { head :ok }
    end
  end
end
