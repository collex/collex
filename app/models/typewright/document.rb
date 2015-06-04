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

class Typewright::Document < ActiveResource::Base
	if COLLEX_PLUGINS['typewright']
		self.site = COLLEX_PLUGINS['typewright']['web_service_url']
	end
	self.format = :xml

	def self.find_by_uri(uri)
		self.find(:first, :params => { :uri => uri })
	end

	def self.find_by_id(id)
		begin
		   self.find(:first, :params => { :id => id })
		rescue
			return nil
		end
	end

	def self.get_stats(uri, word_stats)
		if word_stats
			self.find(:first, :params => { :id => uri, :stats => true, :wordstats=> word_stats })
		else
			self.find(:first, :params => { :id => uri, :stats => true })
		end
	end

   def self.get_page(uri, page, word_stats)
      if word_stats
         doc = self.find(:first, :params => { :id => uri, :page => page, :wordstats=> word_stats })
      else
         doc = self.find(:first, :params => { :id => uri, :page => page })
      end
      # convert object into hash since that is what page is expecting
      result = doc.attributes.to_options!
      result[:img_size] = result[:img_size].attributes.to_options!
      result[:lines].each_with_index do |line, idx|
         result[:lines][idx] = line.attributes.to_options!
         unless result[:lines][idx][:authors].nil?
            result[:lines][idx][:authors].each_with_index do |author, auth_idx|
               result[:lines][idx][:authors][auth_idx] = Typewright::User.get_author_username(author.federation, author.orig_id)
            end
         end
      end
      return result
   end

  def self.get_report_form_url(id, user_id, fullname, email, page)
	  form_url = "#{self.site}documents/#{id}/report?page=#{page}&user_id=#{user_id}&fullname=#{fullname}&email=#{email}"
    return form_url
  end

	def book_id()
		return self.uri.split('/').last
	end

	def thumb()
	  thumb = COLLEX_PLUGINS['typewright']['web_service_url'] + self.img_thumb
	  return thumb
	end

	def get_title()
	  return self.title
	end

end
