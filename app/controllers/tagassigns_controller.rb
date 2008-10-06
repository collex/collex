class TagassignsController < ApplicationController
  # GET /tagassigns
  # GET /tagassigns.xml
  def index
    @tagassigns = Tagassign.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tagassigns }
    end
  end

  # GET /tagassigns/1
  # GET /tagassigns/1.xml
  def show
    @tagassign = Tagassign.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tagassign }
    end
  end

  # GET /tagassigns/new
  # GET /tagassigns/new.xml
  def new
    @tagassign = Tagassign.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tagassign }
    end
  end

  # GET /tagassigns/1/edit
  def edit
    @tagassign = Tagassign.find(params[:id])
  end

  # POST /tagassigns
  # POST /tagassigns.xml
  def create
    @tagassign = Tagassign.new(params[:tagassign])

    respond_to do |format|
      if @tagassign.save
        flash[:notice] = 'Tagassign was successfully created.'
        format.html { redirect_to(@tagassign) }
        format.xml  { render :xml => @tagassign, :status => :created, :location => @tagassign }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tagassign.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tagassigns/1
  # PUT /tagassigns/1.xml
  def update
    @tagassign = Tagassign.find(params[:id])

    respond_to do |format|
      if @tagassign.update_attributes(params[:tagassign])
        flash[:notice] = 'Tagassign was successfully updated.'
        format.html { redirect_to(@tagassign) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tagassign.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tagassigns/1
  # DELETE /tagassigns/1.xml
  def destroy
    @tagassign = Tagassign.find(params[:id])
    @tagassign.destroy

    respond_to do |format|
      format.html { redirect_to(tagassigns_url) }
      format.xml  { head :ok }
    end
  end
end
