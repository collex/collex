class EmailWaiting < ActiveRecord::Base

	def self.cue_email(from_name, from_email, to_name, to_email, subject, body, return_url, suffix)
	  GenericMailer.generic(from_name, from_email, to_name, to_email, subject, body, return_url, suffix).deliver
	end
end
