require 'decompress'
require 'yaml'

class UploadController < ApplicationController  
	def index
		@contributors = Contributor.list_all_contributors
	end
  
	def thankyou
	end

	def save_file
	    tree = YAML::parse(File.open(RAILS_ROOT+"/config/database.yml"))
		obj_tree = tree.transform
		dirA = obj_tree['java_constants']['dir1']
		dirB = obj_tree['java_constants']['dir2']
		if params[:archive_name] == "" || (params[:file].length < 2)
			flash[:notice] = "<h3>Please Complete all Form Fields.</h3><p>Please select an archive from the dropdown menu (or add one by clicking 'Add a new Archive'), and specify a file to upload.</p>"
			redirect_to :action => 'index'
		else
			@fname = File.basename(params['file'].original_filename)
			
			# Instantiates @contri_dir as the appropriate id column of the contributors table
			archive_name = params['archive_name']
			@contributors = Contributor.find_by_archive_name(archive_name)
			@contri_dir = @contributors.id.to_s
							
		    if @fname.match('\s')
		    	flash[:notice] = "<h3>Error processing file.</h3><p>Filename may not contain spaces.  Please rename the file and upload it again.</p>"
		    	redirect_to :action => 'index'
		    else
		    	if
		    		# Change this location to reflect the desired file upload directory
		               File.open(dirA+"/#{@contri_dir}/#{@fname}", "wb") do |f| 
		    			f.write(params['file'].read)
		   			end
				end
		    	if @fname.match('.zip')
		    		# Change this location to the location specified above, where it will find 	the .zip	
		    		# 	(The decompres.rb file referenced below also specifies a path 
		    		#	for unzipped files - this should be changed to the path above + "/unzip/")
	 	              Decompress.new(dirA+"/#{@contri_dir}/#{@fname}", @contri_dir)
		     	end	     	
		     	#redirect_to :action => 'thankyou'
		     	flash[:notice] = "<h3>Thank You for your submission.</h3> <p>It is being processed. You will receive an email once the processing is complete.</p>"
		     	redirect_to '/upload'
			end
		end
	end
end
