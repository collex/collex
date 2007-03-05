require 'zip/zipfilesystem'
require 'fileutils'
require 'zip/zip'
require 'yaml'

class Decompress
  
  def initialize(file, dir)
   
      	
        
      self.extract(file,dir)
       
  end
  def extract(file,dir)
  newfilename = file[0,file.length-4]+".rdf"
  filenumber = 0
   while File.exist?(newfilename) 
        newfilename = newfilename[0,newfilename.length-4]+filenumber.to_s+".rdf"
		filenumber=filenumber+1
	end

	
  
  
  aFile = File.new(newfilename, "w")
  Zip::ZipFile::open(file) {
  |zf| zf.each { |e|
 


      aFile.print(zf.read(e.name))
	  
    
  }
  
 
  }
  aFile.close	

  FileUtils::rm(file)
  end
  
  end
