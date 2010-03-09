class EmailWaiting < ActiveRecord::Base
	def self.periodic_update
		return { :activity => false }
	end

	def self.cue_email(from_name, from_email, to_name, to_email, subject, body)
		EmailWaiting.create({ :from_name => from_name, :from_email => from_email, :to_name => to_name,
			:to_email => to_email, :subject => subject, :body => body })
		puts "---------------------"
		puts "cue_email:"
		puts "from: #{from_name} #{from_email}"
		puts "to: #{to_name} #{to_email}"
		puts "subject: #{subject}"
		puts body
		puts "----------------------"
	end
end
