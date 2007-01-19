require 'zip/zipfilesystem'
require 'fileutils'
require 'zip/zip'
require 'yaml'

class Decompress
  
  def initialize(file, dir)
    
      	
        
      self.extract(file,dir)
       
  end
  def extract(file,dir)
  
  ##unzip_dir="./out"
  Zip::ZipFile::open(file) {
  |zf| zf.each { |e|
  tree = YAML::parse(File.open(RAILS_ROOT+"/config/database.yml"))
		obj_tree = tree.transform
		dirA = obj_tree['java_constants']['dir1']
  @fpath = dirA+"/"+dir+"/"+ e.name
   if (File.exist?(@fpath)) 
        FileUtils::rm(@fpath)
   end
  	zf.extract(e,@fpath) 
   	

  } }

  FileUtils::rm(file)
  end
  
  end
