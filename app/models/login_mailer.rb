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

class LoginMailer < ActionMailer::Base

  helper ActionView::Helpers::UrlHelper

	#
	# Generic email
	#
	def generic(from_name, from_email, to_name, to_email, subject, body, return_url, suffix)
		@subject    = "[#{SITE_NAME}] #{subject}"
		@body       = "#{body}\n\nThis message was sent to you by #{SITE_NAME}  (#{return_url}). #{suffix}\n"
		@recipients = "#{to_name} <#{to_email}>"
		@from       =  "#{from_name} <#{from_email}>"
		@reply_to = "#{from_name} <#{from_email}>"
		@headers    = { "return-path" =>  "#{from_name} <#{from_email}>" }
	end
end
