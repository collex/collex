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

  def password_reset(params)
    @subject    = 'Collex Password Reset'
    @body       = params
    @recipients = params[:user][:email]
    @from       = 'mailto:technologies@nines.org'
    @headers    = {}
  end
  
  def recover_username(params)
    @subject    = 'Collex User Name'
    @body       = params
    @recipients = params[:user][:email]
    @from       = 'mailto:technologies@nines.org'
    @headers    = {}
  end

	def report_abuse_to_admin(params, recipient)
    @subject    = '[NINES] Comment Abuse Reported'
    @body       = params
    @recipients = recipient
    @from       = 'mailto:technologies@nines.org'
    @headers    = {}
	end

	def cancel_abuse_report_to_reporter(params, recipient)
    @subject    = '[NINES] Abusive Comment Report Canceled'
    @body       = params
    @recipients = recipient
    @from       = 'mailto:technologies@nines.org'
    @headers    = {}
	end

	def accept_abuse_report_to_reporter(params, recipient)
    @subject    = '[NINES] Abusive Comment Report Accepted'
    @body       = params
    @recipients = recipient
    @from       = 'mailto:technologies@nines.org'
    @headers    = {}
	end

	def accept_abuse_report_to_commenter(params, recipient)
    @subject    = '[NINES] Abusive Comment Deleted'
    @body       = params
    @recipients = recipient
    @from       = 'mailto:technologies@nines.org'
    @headers    = {}
	end
end
