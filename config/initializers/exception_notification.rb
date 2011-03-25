config_file = File.join(Rails.root, "config", "site.yml")
if File.exists?(config_file)
	site_specific = YAML.load_file(config_file)
	EXCEPTION_PREFIX = site_specific['exception_notifier']['email_prefix']
	EXCEPTION_RECIPIENTS = site_specific['exception_notifier']['exception_recipients']
	EXCEPTION_SENDER = site_specific['exception_notifier']['sender_address']

	if Rails.env.to_s != 'development'
		Collex::Application.config.middleware.use ExceptionNotifier,
			:email_prefix => EXCEPTION_PREFIX,
			:sender_address => EXCEPTION_SENDER,
			:exception_recipients => EXCEPTION_RECIPIENTS.split(' ')
	end
end
