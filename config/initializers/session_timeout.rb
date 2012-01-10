#Rails.application.config.idle_session_timeout = 4*60 #minutes
Collex::Application.config.idle_session_timeout = 4*60 #minutes

# We want the session to time out always, not only when logged in.
# Also, the criterion for whether the session is logged in is not recognized by Collex.
module Ixtlan
	module Sessions
		module Timeout
			# The gem only does timeouts if current_user is defined and returns true. We want to clear the
			# session whether logged in or not, and current_user isn't the way we define that someone is logged in, anyway.
			def logged_in?
				return true
			end

			# The gem will redirect when it times out, but we don't want that.
			def session_timeout
			  respond_to do |format|
				format.html {
					@notice = "=== Session has timed out due to inactivity. ==="
				  #@notice = "session timeout" unless @notice
				  #redirect_to ""
				}
				format.xml { head :unauthorized }
			  end
			end
		end
	end
end
