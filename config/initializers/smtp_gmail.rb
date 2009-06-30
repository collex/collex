require "smtp_tls"

ActionMailer::Base.smtp_settings = {
  :address => "smtp.gmail.com",
  :port => 587,
  :user_name => 'edward@performantsoftware.com',
  :password => 'testing',
  :authentication => :plain
}
