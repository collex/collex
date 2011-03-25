# config/initializers/setup_mail.rb
config_file = File.join(Rails.root, "config", "site.yml")
if File.exists?(config_file)
	site_specific = YAML.load_file(config_file)

	ActionMailer::Base.smtp_settings = {
		:address => site_specific['smtp_settings']['address'],
		:port => site_specific['smtp_settings']['port'],
		:domain => site_specific['smtp_settings']['domain'],
		:user_name => site_specific['smtp_settings']['user_name'],
		:password => site_specific['smtp_settings']['password'],
		:authentication => site_specific['smtp_settings']['authentication'],
		:enable_starttls_auto => true
	}

	ActionMailer::Base.default_url_options[:host] = site_specific['smtp_settings']['return_path']
	#Mail.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?
else
	puts "***"
	puts "*** Failed to load site configuration. Did you create config/site.yml?"
	puts "***"
end

