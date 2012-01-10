#Rails.application.config.idle_session_timeout = 4*60 #minutes
Collex::Application.config.idle_session_timeout = 4*60 #minutes

# We want the session to time out always, not only when logged in.
# Also, the criterion for whether the session is logged in is not recognized by Collex.
module Ixtlan
	module Sessions
		module Timeout
			def logged_in?
				return true
			end
		end
	end
end
