##########################################################################
# Copyright 2007 Applied Research in Patacriticism and the University of Virginia
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################

require 'digest/sha1'

class UsernameAlreadyExistsException < StandardError
end

class NinesCollectionManager
  def initialize
    @solr = CollexEngine.new
  end
  
  def logger=(logger)
    @logger = logger
  end
  
  def login(username, password)
    hashed_password = password_hash(password)
    
    user = User.find_by_username_and_password_hash(username, hashed_password)
    
    return user ? {:username => user.username, :fullname => user.fullname, :email => user.email, :role_names => user.role_names} : nil
  end
  
  def create_user(username, password, email)
    # first check if user exists, then raise an exception if so
    user = User.find_by_username(username)
    
    raise(UsernameAlreadyExistsException, "User #{username} already exists", caller) if user
    
    hashed_password = password_hash(password)

    user = User.create(:username => username, :fullname => username, :password_hash => hashed_password, :email => email)
    user.save
    
    {:username => username, :fullname => username, :email => email, :role_names => user.role_names}
  end
  
  def update_user(username, password, email)
    user = User.find_by_username(username)
    user.email = email
    if password != ""
      user.password_hash = password_hash(password)
    end
    user.save
    
    {:username => username, :fullname => user.fullname, :email => email, :role_names => user.role_names}
  end
  
  def reset_password(username)
    new_password = generate_password
    user = User.find_by_username(username)
    if user
      user.password_hash = password_hash(new_password)
      user.save
      return {:username => username, :fullname => user.fullname, :email => user.email, :new_password => new_password, :role_names => user.role_names}
    else
      return nil
    end
  end
  
  def find_by_email(email)
    return User.find(:first, :conditions => [ "email = ?", email ] )
  end
  
  # Through the nines model, return objects that match the given URL, along with their title and thumbnail URL.
  def objects_behind_urls(urls, user)
    @solr.objects_behind_urls(urls,user)
  end
  
  # per user or global cloud of collected objects, counts per type
  def cloud(type, user = nil)
    if type == "tag" && user != nil
      # "tag" is a special - don't want to see tags that others have put on _my_ objects (well, not in the cloud at least for now)
      # so, facet on <username>_tag when tag cloud is requested for a specific user
      type = "#{user}_tag"
    end
    constraint = user ? FacetConstraint.new(:field => "username", :value => user) : ExpressionConstraint.new(:value => "username:[* TO *]")
    @solr.facet(type, [constraint])
  end
  
  def objects_by_type(type, value, user = nil, start = 0, max = 5)
    if type == "tag" && user != nil
      # when asking for a tag list by username, need to use the <username>_tag field instead of just "tag"
      type = "#{user}_tag"
    end
    constraints = [FacetConstraint.new(:field => type, :value => value)]
    if user
      constraints << FacetConstraint.new(:field => "username", :value => user)
    else
      constraints << ExpressionConstraint.new(:value => "username:[* TO *]")  # these are the collected objects, any with a username value
    end
    
    # TODO: highlighting not necessary in this context, but still requested
    @solr.search(constraints, start, max, nil)
  end
  
  def object_detail(objid, user)
    @solr.object_detail(objid, user)
  end
      
  def relators
    hash = Hash.new {|hash,key| hash[key] = key}
    hash["ART"] = "Artist"
    hash["AUT"] = "Author"
    hash["EDT"] = "Editor"
    hash["PBL"] = "Publisher"
    hash["TRL"] = "Translator"
    hash["CTY"] = "City"
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


