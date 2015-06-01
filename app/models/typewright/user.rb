# ------------------------------------------------------------------------
#     Copyright 2011 Applied Research in Patacriticism and the University of Virginia
#
#     Licensed under the Apache License, Version 2.0 (the "License");
#     you may not use this file except in compliance with the License.
#     You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.
# ----------------------------------------------------------------------------

class Typewright::User < ActiveResource::Base
   if COLLEX_PLUGINS['typewright']
      self.site = COLLEX_PLUGINS['typewright']['web_service_url']
   end
   self.format = :xml

   def self.get_author_fullname(federation, orig_id)
      return orig_id if federation.nil?
      if federation == Setup.default_federation()
         user = ::User.find_by_id(orig_id)
         return user.fullname if user
      end
      return "#{federation} User"
   end

   def self.get_author_username(federation, orig_id)
      return orig_id if federation.nil?
      if federation == Setup.default_federation()
         user = ::User.find_by_id(orig_id)
         return user.username if user
      end
      return "#{federation} User"
   end

   def self.get_author_native_rec(federation, orig_id)
      return nil if federation.nil?
      if federation == Setup.default_federation()
         return ::User.find_by_id(orig_id)
      end
      return nil
   end

   def self.get_user(federation, orig_id)
      user = self.find(:first, :params => { :federation => federation, :orig_id => orig_id })
      return user
   end

   def self.get_or_create_user(federation, orig_id, username)
      user = self.get_user(federation, orig_id)
      if user == nil
         user = self.create({ :federation => federation, :orig_id => orig_id, :username => username })
      end
      return user
   end
end
