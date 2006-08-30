require 'digest/sha1'

class UsernameAlreadyExistsException < StandardError
end

class NinesCollectionManager
  def initialize
    @solr = Solr.new
  end
  
  def logger=(logger)
    @logger = logger
  end
  
  def login(username, password)
    hashed_password = password_hash(password)
    
    user = User.find_by_username_and_password_hash(username, hashed_password)
    
    return user ? {:username => user.username, :fullname => user.fullname, :email => user.email} : nil
  end
  
  def create_user(username, password, fullname, email)
    # first check if user exists, then raise an exception if so
    user = User.find_by_username(username)
    
    raise(UsernameAlreadyExistsException, "User #{username} already exists", caller) if user
    
    hashed_password = password_hash(password)

    user = User.create(:username => username, :password_hash => hashed_password, :fullname => fullname, :email => email)
    user.save
    
    {:username => username, :fullname => fullname, :email => email}
  end
  
  def update_user(username, password, fullname, email)
    user = User.find_by_username(username)
    user.fullname = fullname
    user.email = email
    if password != ""
      user.password_hash = password_hash(password)
    end
    user.save
    
    {:username => username, :fullname => fullname, :email => email}
  end
  
  def reset_password(username)
    new_password = generate_password
    user = User.find_by_username(username)
    if user
      user.password_hash = password_hash(new_password)
      user.save
      return {:username => username, :fullname => user.fullname, :email => user.email, :new_password => new_password}
    else
      return nil
    end
  end
  
  # Through the nines model, return objects that match the given URL, along with their title and thumbnail URL.
  def objects_behind_urls(urls, user)
    @solr.objects_behind_urls(urls,user)
  end
  
  #TODO: eliminate the need for commit/optimize for the add/update/remove operations
  
  # Adds pointers 
  def add(username, collectables)    
    @solr.add(username, collectables)
    @solr.commit
  end
  
  def update(username, uri, tags, annotation)
    @solr.update(username, uri, tags, annotation)
    @solr.commit
  end
    
  def remove(username, uri)
    @solr.remove(username,uri)
    @solr.commit
  end

  def cloud(type, user = nil)
    @solr.facet(type, [{:field => "collected", :value => "collected"}], nil, nil, user)
  end
  
  def objects_by_type(type, value, user = nil)
    constraints = [{:field => type, :value => value}]
    if user
      constraints << {:field => "username", :value => user}
    else
      constraints << {:field => "collected", :value => "collected"}
    end
    @solr.search(constraints, 0, 200)
  end
  
  def object_detail(objid, user)
    @solr.object_detail(objid, user)
  end
      
  def relators
    hash = Hash.new {|hash,key| hash[key] = key}
    hash["ART"] = "Artist"
    hash["AUT"] = "Author"
    hash["CRE"] = "Creator"
    hash["EDT"] = "Editor"
    hash["OWN"] = "Owner"
    hash["PBL"] = "Publisher"
    hash["PHT"] = "Photographer"
    hash["TRL"] = "Translator"
    hash
  end

  private
  def generate_password
    len = 8
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    newpass
  end
  
  def password_hash(password)
    Digest::SHA1.hexdigest(password)
  end
end


