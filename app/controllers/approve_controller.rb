require 'net/http'
require 'post_to_solr'
require 'yaml'

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
   
  def destroy
  tree = YAML::parse(File.open(RAILS_ROOT+"/config/database.yml"))
		obj_tree = tree.transform
		dirA = obj_tree['java_constants']['dir1']
		dirB = obj_tree['java_constants']['dir2']
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
  	
  	FileUtils::rm(RAILS_ROOT+"/"+dirB+"/#{@contri_dir}/#{@fname}")  	
  	
  	@task.destroy
    
    flash[:notice] = "<h3>Titles deleted.</h3><p>Your titles were deleted successfully.</p>"
    redirect_to :action => 'index'
  end
  
  def approve
	@titles = Title.find_all_by_task_id(params[:id])
	for title in @titles
		approval = Approval.new(:id => title.id, :task_id => params[:id].to_i, :uri => title.uri, :xml => title.xml)
		if approval.save
			title.destroy
		end
	end
	# Uncomment if you wish to destroy the task record from Ruby
	#@task = Task.find(params[:id])
	#@task.destroy
	
	flash[:notice] = "<h3>Titles approved.</h3><p>Your titles have been successfully approved.  They will be processed and added to NINES shortly.</p>"
	redirect_to :action => 'index'
  end
   
end
