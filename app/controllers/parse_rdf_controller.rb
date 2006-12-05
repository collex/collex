require 'rexml/document'
require 'net/http'
require 'uri'
include REXML
class parse_rdf_controller < ApplicationController
def self(rdfFile)
  acceptableGenres = Array.[]("Secondary","Primary","Criticism","Poetry","Fiction","Drama")
  errorList = Array.new();
  doc = Document.new File.new(rdfFile)
  dcTitle = XPath.match(doc,"//dc:title")
  dcSubject = XPath.match(doc,"//dc:subject")
  dcDate = XPath.match(doc,"//dc:date")
  ninesGenre = XPath.match(doc,"//nines:genre")
  ninesArchive = XPath.match(doc,"//nines:archive")
  genreType = nil
  role = Array.new()
  allLinks = Array.new()
  rdfAbout = ""
  alldoc = XPath.match(doc.root,"//*").each do |element|
 #puts element.prefix
    if element.attributes["rdf:about"] 
      if rdfAbout==""
      rdfAbout = element.attributes["rdf:about"] 
      else
      @errorList<<"More than one rdf:about tag"
      end
    end  
    if element.attributes["rdf:resource"] 
      
      allLinks<<element.attributes["rdf:resource"] 
    
    end 
    if element.prefix == "role"
      role<<element.name
    end
  end
  dcSubject.each do |onesubject|
    
    if onesubject.text.match('\s')
     
    errorList<<"Subject: "+onesubject.text+" contains a space"
       puts errorList.length
    end
  
  end
  ninesGenre.each do |thisGenre|
  if (thisGenre == "Primary") || (thisGenre=="Secondary")
    if (genreType)
      errorList<<"Conflicting genre types:  Both Primary and Secondary present"
    else
      genreType = thisGenre
    end
  end
  if not (acceptableGenres.include?(thisGenre.text))
     
     errorList<<(thisGenre.text+" is not an acceptable value for nines:genre")
  end   
  end
  if role.length=0
  errorList<<"No role entered"
  end
  errorList<<testLinks(allLinks)
  return { 'title' => dcTitle, 'subject' => dcSubject, 'date' => dcDate, 'genres'=>ninesGenre, 'archive'=>ninesArchive, 'genreType'=>genreType, 'role'=>role, 'externalLinks'=>allLinks, 'errors'=>errorList }

end
def testLinks(linkList)
  errorList = Array.new()
  linkList.each do |thisURL|
  begin
  Net::HTTP.get_response(URI.parse(thisURL)).message 
  rescue
  errorList<<(thisURL+ "is not valid")
  end


  
  end
  return errorList
end

end
