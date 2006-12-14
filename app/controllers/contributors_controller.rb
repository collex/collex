require 'fileutils'

class ContributorsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @contributor_pages, @contributors = paginate :contributors, :per_page => 10
  end

  def show
    @contributor = Contributor.find(params[:id])
  end

  def new
    @contributor = Contributor.new
  end

  def create
    @contributor = Contributor.new(params[:contributor])
    
    if @contributor.save
      	archive_name = params[:contributor]['archive_name']
		@contribs = Contributor.find_by_archive_name(archive_name)

		@contri_dir = @contribs.id.to_s		
    
    
	  #FileUtils::mkdir( RAILS_ROOT+"/rdf_test/"+params[:contributor]['archive_name'] )
      FileUtils::mkdir( RAILS_ROOT+"/rdf_test/"+@contri_dir )
      flash[:notice] = '<h3>Archive was successfully created.</h3><p>You can now select this Archive from the "Select an Archive" dropdown menu.</p>'
      redirect_to '/upload'
    else
      render :action => 'new'
    end
  end

  def edit
    @contributor = Contributor.find(params[:id])
  end

  def update
    @contributor = Contributor.find(params[:id])
    if @contributor.update_attributes(params[:contributor])
      flash[:notice] = 'Contributor was successfully updated.'
      redirect_to :action => 'show', :id => @contributor
	flash[:notice] = params['contributor']
    else
      render :action => 'edit'
    end
  end

  def destroy
    Contributor.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
