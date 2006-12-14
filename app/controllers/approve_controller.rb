require 'net/http'
require 'post_to_solr'

class ApproveController < ApplicationController
  def index
    @title_pages = paginate :titles, :per_page => 10
    @titles = Title.find_all
    @tasks = Task.find_all
    render :action => 'list'
  end
  
  def show
    @title = Title.find(params[:id])
  end
  
  def titles
  	@titles = Title.find_all_by_task_id(params[:id])
  	@task = Task.find(params[:id])
  	@contributor = Contributor.find_by_archive_name(@task.archive_name)
  end
  
   #####################################
   
  def destroy
  	@task = Task.find(params[:id])
  	thistaskidstring = params[:id].to_s
  	@deltitles = Title.find_all_by_task_id(thistaskidstring)
	for deltitle in @deltitles
		deltitle.destroy
	end
		
  	archive_name = @task.archive_name
	@contribs = Contributor.find_by_archive_name(archive_name)
	@contri_dir = @contribs.id.to_s	
	@fname = @task.file_name
  	
  	FileUtils::rm(RAILS_ROOT+"/rdf_test/#{@contri_dir}/#{@fname}")  	
  	
  	@task.destroy
    
    redirect_to :action => 'index'
  end
  
  def approve
  	#Title.find(params[:id]).destroy
  	@titles = Title.find_all_by_task_id(params[:id])
  	for title in @titles
  		@uri = title.uri
  		@solr_xml = "<drop><uri>#{@uri}</uri></drop>"
		TestHTTP.new(@solr_xml)
		
		@xml = title.xml
		TestHTTP.new(@xml)		
  	end
  	redirect_to :action => 'index'
  end
   
end
