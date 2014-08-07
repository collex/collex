##########################################################################
# Copyright 2009 Applied Research in Patacriticism and the University of Virginia
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

class LoginInfo < ActiveRecord::Base
	def self.record_login(user)
		LoginInfo.create({ :username => user[:username], :action => 'login', :address => nil })
	end

	def self.record_logout(username)
		if username
			LoginInfo.create({ :username => username, :action => 'logout', :address => nil })
		end
	end

	def self.record_bad_login(name, origin)
		arr = origin.split(' ')
		LoginInfo.create({ :username => name, :address => arr[0],:action => 'bad_login_attempt' })
	end

	def self.record_signup(name)
			LoginInfo.create({ :username => name, :action => 'signup', :address => nil })
	end

	def self.get_stats()
		day = 1.day.ago
		week = 1.week.ago
		month = 30.days.ago
		year = 1.year.ago

		recs = LoginInfo.all()
		unique_logins_today = {}
		unique_logins_this_week = {}
		unique_logins_this_month = {}
		unique_logins_this_year = {}
		signups_today = {}
		signups_this_week = {}
		signups_this_month = {}
		signups_this_year = {}
		recs.each { |rec|
			if rec.action == 'login' && rec.updated_at > day
				unique_logins_today[rec.username] = true
			end
			if rec.action == 'login' && rec.updated_at > week
				unique_logins_this_week[rec.username] = true
			end
			if rec.action == 'login' && rec.updated_at > month
				unique_logins_this_month[rec.username] = true
			end
			if rec.action == 'login' && rec.updated_at > year
				unique_logins_this_year[rec.username] = true
			end
			if rec.action == 'signup' && rec.updated_at > day
				signups_today[rec.username] = true
			end
			if rec.action == 'signup' && rec.updated_at > week
				signups_this_week[rec.username] = true
			end
			if rec.action == 'signup' && rec.updated_at > month
				signups_this_month[rec.username] = true
			end
			if rec.action == 'signup' && rec.updated_at > year
				signups_this_year[rec.username] = true
			end
		}

		return { :all_recs => recs, :unique_logins_today => unique_logins_today.length, :unique_logins_this_week => unique_logins_this_week.length,
			:unique_logins_this_month => unique_logins_this_month.length, :unique_logins_this_year => unique_logins_this_year.length,
			:signups_today => signups_today.length, :signups_this_week => signups_this_week.length,
			:signups_this_month => signups_this_month.length, :signups_this_year => signups_this_year.length
		}
	end
end
