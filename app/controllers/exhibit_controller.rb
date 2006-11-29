class ExhibitController < ApplicationController
  before_filter :authorize
  layout "nines"
  
  def mine
    @exhibit_types = ExhibitType.find(:all)
    
    # TODO: look up all exhibits owned by the current user
  end
  
  def new
    @exhibit = Exhibit.new(:title => "<New>")
    @exhibit.exhibit_type = ExhibitType.find(params[:type])
    render :action => 'edit'
  end
  
  def edit
    @exhibit = Exhibit.find(params[:id])
  end
  
  def add_section
    exhibit =  Exhibit.find(params[:exhibit_id])
    section = Section.new(:section_type => SectionType.find(params[:section_type_id]))
    exhibit.sections << section
    exhibit.save
    redirect_to :action => 'edit', :id => exhibit.id
  end
  
  def update
    @exhibit = Exhibit.new(params[:exhibit])
    @exhibit.user = User.find_by_username(session[:user][:username])
    @exhibit.save
    redirect_to :action => 'edit', :id => @exhibit
  end
end
