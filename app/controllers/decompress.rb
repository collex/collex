require 'zip/zipfilesystem'
require 'fileutils'
require 'zip/zip'

class Decompress
  
  def initialize(file, dir)
    
      	
        
      self.extract(file,dir)
       
  end
  def extract(file,dir)
  
  ##unzip_dir="./out"
  Zip::ZipFile::open(file) {
  |zf| zf.each { |e|
  
  @fpath = "/testA/rdf_test/"+dir+"/"+ e.name;
  puts @fpath
  zf.extract(e,@fpath) 

  } }

  FileUtils::rm(file)
  end
  
  end
