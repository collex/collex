class CollectedItemsController < ApplicationController
#  # GET /collected_items
#  # GET /collected_items.xml
#  def index
#    @collected_items = CollectedItem.find(:all)
#
#    respond_to do |format|
#      format.html # index.html.erb
#      format.xml  { render :xml => @collected_items }
#    end
#  end
#
#  # GET /collected_items/1
#  # GET /collected_items/1.xml
#  def show
#    @collected_item = CollectedItem.find(params[:id])
#
#    respond_to do |format|
#      format.html # show.html.erb
#      format.xml  { render :xml => @collected_item }
#    end
#  end
#
#  # GET /collected_items/new
#  # GET /collected_items/new.xml
#  def new
#    @collected_item = CollectedItem.new
#
#    respond_to do |format|
#      format.html # new.html.erb
#      format.xml  { render :xml => @collected_item }
#    end
#  end
#
#  # GET /collected_items/1/edit
#  def edit
#    @collected_item = CollectedItem.find(params[:id])
#  end
#
#  # POST /collected_items
#  # POST /collected_items.xml
#  def create
#    @collected_item = CollectedItem.new(params[:collected_item])
#
#    respond_to do |format|
#      if @collected_item.save
#        flash[:notice] = 'CollectedItem was successfully created.'
#        format.html { redirect_to(@collected_item) }
#        format.xml  { render :xml => @collected_item, :status => :created, :location => @collected_item }
#      else
#        format.html { render :action => "new" }
#        format.xml  { render :xml => @collected_item.errors, :status => :unprocessable_entity }
#      end
#    end
#  end
#
#  # PUT /collected_items/1
#  # PUT /collected_items/1.xml
#  def update
#    @collected_item = CollectedItem.find(params[:id])
#
#    respond_to do |format|
#      if @collected_item.update_attributes(params[:collected_item])
#        flash[:notice] = 'CollectedItem was successfully updated.'
#        format.html { redirect_to(@collected_item) }
#        format.xml  { head :ok }
#      else
#        format.html { render :action => "edit" }
#        format.xml  { render :xml => @collected_item.errors, :status => :unprocessable_entity }
#      end
#    end
#  end
#
#  # DELETE /collected_items/1
#  # DELETE /collected_items/1.xml
#  def destroy
#    @collected_item = CollectedItem.find(params[:id])
#    @collected_item.destroy
#
#    respond_to do |format|
#      format.html { redirect_to(collected_items_url) }
#      format.xml  { head :ok }
#    end
#  end
end
