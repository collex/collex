class EmailWaiting < ActiveRecord::Base
	def self.periodic_update
		emails = EmailWaiting.all
		return { :activity => false } if emails.length == 0

		emails.each{|email|
			GenericMailer.generic(email.from_name, email.from_email, email.to_name, email.to_email, email.subject, email.body, email.return_url, email.suffix).deliver
			email.destroy
		}
		return { :activity => true, :message => "Number of emails sent: #{emails.length}" }
	end

	def self.cue_email(from_name, from_email, to_name, to_email, subject, body, return_url, suffix)
		EmailWaiting.create({ :from_name => from_name, :from_email => from_email, :to_name => to_name,
			:to_email => to_email, :subject => subject, :body => body, :return_url => return_url, :suffix => suffix })
		puts "---------------------"
		puts "cue_email:"
		puts "from: #{from_name} #{from_email}"
		puts "to: #{to_name} #{to_email}"
		puts "subject: #{subject}"
		puts body
		puts "suffix: #{suffix}"
		puts "----------------------"
	end
end
