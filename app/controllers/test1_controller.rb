require 'zip/zipfilesystem'
require 'unzipRuby'
require 'writedb'

#class Test1Controller < ApplicationController
#  def file_upload
#  end
#  
#  def thankyou
#  end
#
#  def save_file
#    #fbody = @params['file']
#    
#    @fname = self.uploaded_file = @params['file']
#    File.open("/Users/abhishta/rdf_test/#{@fname}", "wb") do |f| 
#      f.write(@params['file'].read)
#    end
#    redirect_to :action => 'thankyou'
#  end
#  
#  def uploaded_file=(incoming_file)
#    @test2 = Test2Controller.new()
#    @test2.file_name = incoming_file.original_filename
#  end
#
#end
#
#class Test2Controller
#
#  def file_name=(new_file_name)
#   #write_attribute("file_name", sanitize_filename(new_file_name))
#   self.file_name = sanitize_filename(new_file_name)
#  end
#
#  private
#
#  def sanitize_filename(file_name)
#    # get only the filename, not the whole path (from IE)
#    just_filename = File.basename(file_name) 
#    # replace all non-alphanumeric, underscore or periods with underscores
#    just_filename.gsub(/[^\w\.\-]/,'_') 
#  end
#
#end

#unzip_dir="out"

class Test1Controller < ApplicationController
  
	def file_upload
		@contributors = Contributor.list_all_contributors
	end
  
	def thankyou
	end
	
	def index 
	end 

	def save_file
		#fbody = @params['file']
		
		@fname = File.basename(@params['file'].original_filename)
	    
	    #self.uploaded_file = @params['file']
	    #File.open("/Users/abhishta/rdf_test/#{@fname}", "w") do |f|
	    if @fname.match('\s')
	    	redirect_to :action => 'sorrypal'
	    else
	    	if
			    File.open("/Users/dougreside/rdf_test/#{@fname}", "wb") do |f| 
	    			f.write(@params['file'].read)
	    			#redirect_to :action => 'thankyou'
	   			end
			end
	    	if @fname.match('.zip')
	     		#unzip(File)	     		
	     		#unzip("/Users/dougreside/rdf_test/#{@fname}")
	    		UnzipRuby.new("/Users/dougreside/rdf_test/#{@fname}")
	     	end
	     	#redirect_to :action => 'writedb'
	     	Task.new(params[:task])
		end
	end
end




