class AdminController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @title_pages, @titles = paginate :titles, :per_page => 10
  end

  def show_all
    @title_pages, @titles = paginate :titles, :per_page => 10
  end

  def show
    @title = Title.find(params[:id])
  end

  def new
    @title = Title.new
  end
  
  def new_task
  	@task = Task.new
  end

  def create
    @title = Title.new(params[:title])
    if @title.save
      flash[:notice] = 'Title was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end
  
  def create_process
    @title = Title.new(params[:title])
    if @title.save
      flash[:notice] = 'Title was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @title = Title.find(params[:id])
  end

  def update
    @title = Title.find(params[:id])
    if @title.update_attributes(params[:title])
  		flash[:notice] = "Then entries have been successfully updated"
      	redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    Title.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
 end