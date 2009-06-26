class LoginInfo < ActiveRecord::Base
	def self.record_login(user)
		LoginInfo.create({ :username => user[:username], :action => 'login', :address => nil })
	end

	def self.record_logout(session_user)
		if session_user
			LoginInfo.create({ :username => session_user[:username], :action => 'logout', :address => nil })
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
		unique_logins_today = self.unique_recs('login', day)
		unique_logins_this_week = self.unique_recs('login', week)
		unique_logins_this_month = self.unique_recs('login', month)
		unique_logins_this_year = self.unique_recs('login', year)
		signups_today = self.unique_recs('signup', day)
		signups_this_week = self.unique_recs('signup', week)
		signups_this_month = self.unique_recs('signup', month)
		signups_this_year = self.unique_recs('signup', year)

		return { :unique_logins_today => unique_logins_today, :unique_logins_this_week => unique_logins_this_week,
			:unique_logins_this_month => unique_logins_this_month, :unique_logins_this_year => unique_logins_this_year,
			:signups_today => signups_today, :signups_this_week => signups_this_week,
			:signups_this_month => signups_this_month, :signups_this_year => signups_this_year
		}
	end
	
	private
	def self.unique_recs(action, period)
		recs = LoginInfo.all(:conditions => [ 'action = ? AND updated_at > ?', action,  period])
		results = {}
		recs.each { |rec| results[rec.username] = true }
		return results.length
	end
end
