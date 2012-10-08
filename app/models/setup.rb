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

class Setup < ActiveRecord::Base
	@@globals = nil
	def self.reload()
		@@globals = {}
		begin
			# This will fail when installing, before the db has been migrated.
			setup = Setup.all
			setup.each { |rec| @@globals[rec.key] =rec.value }
		rescue
		end

		@@globals['project_manager_email'] = self.process_email_addr(@@globals['project_manager_email'])
		@@globals['webmaster_email'] = self.process_email_addr(@@globals['webmaster_email'])

		self.init_smtp()
		self.init_exception_handler()
	end

	def self.process_email_addr(addr)
		if !addr.blank?
			addr = addr.sub('@', ' ')
			addr = addr.reverse.sub('.', ' ').reverse
		end
		return addr
	end

	def self.globals()
		self.reload() if @@globals.blank?
		return @@globals
	end

	#
	# Public getter functions
	#
	def self.project_manager_email()
		return globals()['project_manager_email']
	end

	def self.webmaster_email()
		return globals()['webmaster_email']
	end

	def self.exception_notifier()
		recipients = globals()['exception_recipients'] ? globals()['exception_recipients'].split(',') : []
		return { prefix: globals()['subject_prefix'], recipients: recipients, sender: "#{globals()['sender_name']} <#{globals()['smtp_user_name']}>" }
	end

	def self.site_name()
		return globals()['site_name']
	end

	def self.site_title()
		return globals()['site_title']
	end

	def self.my_collex()
		return globals()['site_my_collex']
	end

	def self.community_tab()
		val = globals()['site_community_tab']
		val = "Community" if val.blank?
		return val
	end

	def self.community_default_search()
		val = globals()['site_community_default_search']
		val = "Groups" if val.blank?
		return val
	end

	def self.default_federation()
		return globals()['site_default_federation']
	end

	def self.about()
		return { left: { label: globals()['site_about_label_1'], link: globals()['site_about_url_1'] },
			right: { label: globals()['site_about_label_2'], link: globals()['site_about_url_2'] } }
	end

	def self.solr_url()
		val = globals()['site_solr_url']
    return val.present? ? val : "http://arc-staging.performantsoftware.com"
	end

	#
	# Public initialization routines
	#
	def self.init_smtp()
		ActionMailer::Base.smtp_settings = {
			:address => globals()['smtp_address'],
			:port => globals()['smtp_port'],
			:domain => '',
			:user_name => globals()['smtp_user_name'],
			:password => globals()['smtp_password'],
			:authentication => globals()['smtp_authentication'],
			:enable_starttls_auto => true
		}
	end

	def self.init_exception_handler()
		if Rails.env.to_s != 'development'
			n = ExceptionNotifier::Notifier
			except = self.exception_notifier()
			n.default_email_prefix = except[:prefix]
			n.default_exception_recipients = except[:recipients]
			n.default_sender_address = except[:sender]
			puts "$$ Exceptions are mailed to #{except[:recipients].to_s}."
		else
			puts "$$ Exception handler not set in development mode."
		end
  end

  def self.display_community_tab?()
    return true if globals()['enable_community_tab'] != 'false'
    return false
  end

  def self.display_search_tab?()
    return true if globals()['enable_search_tab'] != 'false'
    return false
  end

  def self.display_publications_tab?()
    return true if globals()['enable_publications_tab'] != 'false'
    return false
  end

  def self.display_classroom_tab?()
    return true if globals()['enable_classroom_tab'] != 'false'
    return false
  end

  def self.display_news_tab?()
    return true if globals()['enable_news_tab'] != 'false'
    return false
  end

	def self.analytics_id()
		return nil if globals()['google_analytics'] != 'true'
		return globals()['analytics_id']
	end
end
