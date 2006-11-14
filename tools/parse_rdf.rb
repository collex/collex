require 'rexml/document'
require 'net/http'
require 'uri'
require 'zip/zipfilesystem'

  


include REXML


class ParseRDF
  @@sqlOutput = Hash.new();
  @@errorList = Array.new();
  @@haserrors = false;
  def initialize(file)
   
    acceptableGenres = Array.[]("Secondary","Primary","Criticism","Poetry","Fiction","Drama")
  

     begin
    doc = Document.new(file)
   
    dcTitle = getTexts(XPath.match(doc,"//dc:title"))
    
    dcSubject = getTexts(XPath.match(doc,"//dc:subject"))
    dcDate = getTexts(XPath.match(doc,"//dc:date"))
    ninesGenre = getTexts(XPath.match(doc,"//nines:genre"))
    ninesArchive = getTexts(XPath.match(doc,"//nines:archive"))
    genreType = nil
    role = Array.new()
    allLinks = Array.new()
    rdfAbout = ""
    alldoc = XPath.match(doc.root,"//*").each do |element|
    if element.attributes["rdf:about"] 
      if rdfAbout==""
      rdfAbout = element.attributes["rdf:about"] 
      else
      @@errorList<<"More than one rdf:about tag"
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
    
    if onesubject.match('\s')
     
    @@errorList<<"Subject: "+onesubject+" contains a space"
       
    end
  
  end
  ninesGenre.each do |thisGenre|
  if (thisGenre == "Primary") || (thisGenre=="Secondary")
    if (genreType)
      @@errorList<<"Conflicting genre types:  Both Primary and Secondary present"
    else
      genreType = thisGenre
    end
  end

  if not (acceptableGenres.include?(thisGenre))
     
     @@errorList<<(thisGenre+" is not an acceptable value for nines:genre")
  end   
  end
    if genreType == nil 
    @@errorList<<"Genre not specified as Primary or Secondary"
  end
  if ((not role.length) || role.length==0)
  
  @@errorList<<"No role entered"
  end
testLinks(allLinks)

  if @@errorList.length>0
   @haserrors=true
   
   
  else
  @@sqlOutput = { 'title' => dcTitle, 'subject' => dcSubject, 'date' => dcDate, 'genres'=>ninesGenre, 'archive'=>ninesArchive, 'genreType'=>genreType, 'role'=>role, 'externalLinks'=>allLinks }
   
  end
  rescue 
   

  @@errorList<<$!
  @@haserrors = true
   return @@errorList
  end
  
end

def hasErrors
if @@errorList.length>0
   @@haserrors=true
   
   
  else
    @@haserrors=false
   
  end
  @@haserrors
end
def errors
 @@errorList
end
def sqlOutput
  @@sqlOutput
end

private
def testLinks(linkList)
  
  linkList.each do |thisURL|
    begin
      Net::HTTP.get_response(URI.parse(thisURL)).message 
    rescue
      @@errorList<<(thisURL+ "is not valid")
    end
  end
end
def getTexts(tagArray)
    @textArray = Array.new()
    tagArray.each do |oneelement|   
    @textArray<<oneelement.text

  
  end
  return @textArray
end

end