class ExhibitsController < ApplicationController
  before_filter :authorize
   
  # TODO: Secure this such that one user cannot edit another users Exhibit
   
  def index
    list
    render_action 'list'
  end

  def list
    @exhibit_pages, @exhibits = paginate :exhibit, :per_page => 10
  end

  def show
    @exhibit = Exhibit.find(@params[:id])
  end

  def new
    @exhibit = Exhibit.new
  end

  def create
    @exhibit = Exhibit.new(@params[:exhibit])
    @exhibit.user = session[:user]
    if @exhibit.save
      flash['notice'] = 'Exhibit was successfully created.'
      redirect_to :action => 'list'
    else
      render_action 'new'
    end
  end

  def edit
    @exhibit = Exhibit.find(@params[:id])
  end

  def update
    @exhibit = Exhibit.find(@params[:id])
    if @exhibit.update_attributes(@params[:exhibit])
      flash['notice'] = 'Exhibit was successfully updated.'
      redirect_to :action => 'show', :id => @exhibit
    else
      render_action 'edit'
    end
  end

  def destroy
    Exhibit.find(@params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def add_page
     @exhibit = Exhibit.find(@params[:id])

     page = Page.new
     page.title = "Page #{@exhibit.pages.size + 1}"
     @exhibit.pages << page
     
     if @exhibit.save
        redirect_to :action => "edit", :id => @exhibit
     else
        flash[:notice] = "Error saving"
        render_action 'edit'
     end
  end
end
