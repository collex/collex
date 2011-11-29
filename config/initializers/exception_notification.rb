if Rails.env.to_s != 'development'
	except = Setup.exception_notifier()
	Collex::Application.config.middleware.use ExceptionNotifier,
		:email_prefix => except[:prefix],
		:sender_address => except[:sender],
		:exception_recipients => except[:recipients]
end
