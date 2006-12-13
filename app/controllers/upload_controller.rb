require 'decompress'

class UploadController < ApplicationController
  
	def index
		@contributors = Contributor.list_all_contributors
	end
  
	def thankyou
	end

	def save_file
		@fname = File.basename(@params['file'].original_filename)
		
		# Instantiates @contri_dir as the appropriate id column of the contributors table
		archive_name = params['archive_name']
		@contributors = Contributor.find_by_sql("SELECT id FROM contributors WHERE archive_name = '"+archive_name+"'")
		for contributor in @contributors
			@contri_dir = contributor.id.to_s
		end		
		
		#@contri_dir = params['archive_name'] # Old method - directory names as archive_name
		
	    if @fname.match('\s')
	    	redirect_to :action => 'error_spaces'
	    else
	    	if
	    		# Change this location to reflect the desired file upload directory
                File.open(RAILS_ROOT+"/rdf_test/#{@contri_dir}/#{@fname}", "wb") do |f| 
	    			f.write(@params['file'].read)
	   			end
			end
	    	if @fname.match('.zip')
	    		# Change this location to the location specified above, where it will find the .zip
	    		# 	(The decompres.rb file referenced below also specifies a path 
	    		#	for unzipped files - this should be changed to the path above + "/unzip/")
               Decompress.new(RAILS_ROOT+"/rdf_test/#{@contri_dir}/#{@fname}", @contri_dir)
	     	end	     	
	     	redirect_to :action => 'thankyou'
		end
	end
end
