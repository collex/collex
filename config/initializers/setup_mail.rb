Setup.init_smtp()

# config/initializers/setup_mail.rb
config_file = File.join(Rails.root, "config", "site.yml")
if File.exists?(config_file)

	site_specific = YAML.load_file(config_file)

	ActionMailer::Base.default_url_options[:host] = site_specific['smtp_settings']['return_path']
	#Mail.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?
else
	puts "***"
	puts "*** Failed to load site configuration. Did you create config/site.yml?"
	puts "***"
end

