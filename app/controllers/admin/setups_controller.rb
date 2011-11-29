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
class Admin::SetupsController < Admin::BaseController
	# GET /setups
	# GET /setups.xml
	def index
		setups = Setup.all
		@setups = {}
		setups.each { |setup| @setups[setup.key] = setup.value }
	end

	# PUT /setups/1
	# PUT /setups/1.xml
	def update
		msg = ""
		act = params['commit']
		default_federation = nil
		params['setups'].each { |key,value|
			rec = Setup.find_by_key(key)
			if rec
				default_federation = value if key == 'site_default_federation'
				rec.value = value
				rec.save!
			else
				Setup.create({ key: key, value: value })
			end
		}
		Setup.reload()
		refill_session_cache()

		if act == 'Send Me A Test Email'
			user = get_curr_user()
			GenericMailer.generic(Setup.site_name(), ActionMailer::Base.smtp_settings[:user_name], user[:fullname], user[:email], "Test Email From Collex",
				"If you are reading this, then the email settings are correct in Collex. You should also receive another email soon. If you do not, then there is a problem with the background emailing task.",
				url_for(:controller => '/home', :action => 'index', :only_path => false), "\n--------------\nAutomatic Email from Collex").deliver
			EmailWaiting.cue_email(Setup.site_name(), ActionMailer::Base.smtp_settings[:user_name], user[:fullname], user[:email], "Test Email From Collex - Background delivery",
				"If you are reading this, then the background daemons are setup correctly in Collex and are running.",
				url_for(:controller => '/home', :action => 'index', :only_path => false), "\n--------------\nAutomatic Email from Collex")
			msg = "Two emails should have been sent to the email address on your account. One was sent immediately and the other was sent through the background task."
		elsif act == 'Simulate Error Email'
			raise("This is a test of the error notification system. An administrator pushed the Simulate Error button. If you are reading this, then the error notification system is working correctly.")
		elsif act == 'Test Catalog Connection'
			begin
				solr = Catalog.factory_create(session[:use_test_index] == "true")
				federations = solr.get_federations()
				found = false
				federations.each { |key,val| found = true if default_federation == key }
				if found == true
					msg = "The connection to the Catalog is good."
				else
					msg = "The connection to the Catalog is good, but the federation \"#{default_federation}\" was not found." +
						" The possible federations are: #{federations.map {|key,val| key }.to_s }"
				end
			rescue Catalog::Error => e
				msg = "There is a problem with the connection to the Catalog. Is the URL you've specified correct?"
			end
		else
			msg = "Parameters successfully updated."
		end
		redirect_to :back, :notice => msg
	end

end
