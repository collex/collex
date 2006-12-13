require 'fileutils'

class TitleController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @title_pages = paginate :titles, :per_page => 10
    @titles = Title.find_all
  end

  def show
    @title = Title.find(params[:id])
  end

  def new
    @title = Title.new
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

  def edit
    @title = Title.find(params[:id])
	@tasks = Task.find_all
  end

  def update
    @title = Title.find(params[:id])
    if @title.update_attributes(params[:title])
      flash[:notice] = 'Title was successfully updated.'
      redirect_to :action => 'show', :id => @title
    else
      render :action => 'edit'
    end
  end

  def destroy
  	@thistitle = Title.find(params[:id])
  	thistaskid = @thistitle.task_id
  	@task = Task.find(thistaskid)
  	
  	thistaskidstring = thistaskid.to_s
  	@deltitles = Title.find_by_sql("SELECT * FROM titles WHERE task_id = '"+thistaskidstring +"'")
  	for deltitle in @deltitles
  		Title.find(deltitle.id).destroy
  	end
  	
  	@task.destroy
    redirect_to :action => 'list'
  end
  
  def approve
  	#Title.find(params[:id]).destroy
  	redirect_to :action => 'list'
  end
  
end
