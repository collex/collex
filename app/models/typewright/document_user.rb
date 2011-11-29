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

class Typewright::DocumentUser < ActiveResource::Base
	if COLLEX_PLUGINS['typewright']
		self.site = COLLEX_PLUGINS['typewright']['web_service_url']
	end

	def self.find_all_by_user_id(user_id)
		self.find(:all, :params => { :user_id => user_id })
	end

	def self.find_by_user_id_and_document_id(user_id, document_id)
		self.find(:first, :params => { :user_id => user_id, :document_id => document_id })
	end

	def self.document_list(federation, orig_id)
		user = Typewright::User.get_user(federation, orig_id)
		return [] if user == nil

		docs = Typewright::DocumentUser.find_all_by_user_id(user.id)
		return [] if docs.length == 0

		ret = []
		docs.each { |ud|
			doc = Typewright::Document.find_by_id(ud.document_id)
			ret.push({ :id => ud.id, :uri => doc.uri, :thumbnail => doc.thumb(), :title => doc.get_title() }) unless doc.nil?
		}
		return ret
	end
end
