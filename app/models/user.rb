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

class User < ActiveRecord::Base
  #has_many :interpretations, :dependent => :destroy
  has_many :exhibits
  has_and_belongs_to_many :roles
  has_many :searches
  has_many :collected_items
  belongs_to :image#, :dependent=>:destroy
	has_many :groups
	#TODO-PER: commented for Rails 3: has_and_belongs_to_many :groups
  
  def role_names
    self.roles.collect { |role| role.name }
  end
  
  # Class helper method to get a list of all ADMIN users
  #
  def self.get_administrators
    return User.find(:all, :joins => :roles, :group => :id, :conditions=>"roles.id = 1")
  end
  
  # Added boolean convenience attribute for role names
  def method_missing(method, *args, &block)
    if method.to_s =~ /_role\?$/ 
      role_names.include?(method.to_s[0..-7])
    else
      super
    end
  end

  #
  # Routines from the old NinesCollectionManager
  #

  def self.login(username, password)
    hashed_password = password_hash(password)

    user = User.find_by_username_and_password_hash(username, hashed_password)

    return user ? {:username => user.username, :fullname => user.fullname, :email => user.email, :role_names => user.role_names} : nil
  end

  def self.get_user(user_id)
	  user = User.find_by_id(user_id)

	  return user ? {:username => user.username, :fullname => user.fullname, :email => user.email, :role_names => user.role_names} : nil
  end

  def self.create_user(username, password, email)
    # first check if user exists, then raise an exception if so
    user = User.find_by_username(username)

    raise(UsernameAlreadyExistsException, "User #{username} already exists", caller) if user

    hashed_password = password_hash(password)

    user = User.create(:username => username, :fullname => username, :password_hash => hashed_password, :email => email)
    user.save

    {:username => username, :fullname => username, :email => email, :role_names => user.role_names}
  end

  def self.update_user(username, password, email)
    user = User.find_by_username(username)
    user.email = email
    if password != ""
      user.password_hash = password_hash(password)
    end
    user.save

    {:username => username, :fullname => user.fullname, :email => email, :role_names => user.role_names}
  end

  def self.reset_password(username)
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

  def self.find_by_email(email)
    return User.where({email: email} ).first
  end

  private
  def self.generate_password
    len = 8
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    newpass
  end

  def self.password_hash(password)
    Digest::SHA1.hexdigest(password)
	end
end
