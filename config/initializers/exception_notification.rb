if Rails.env.to_s != 'development'
	except = Setup.exception_notifier()
	Collex::Application.config.middleware.use ExceptionNotification::Rack,
	:email => {
		:email_prefix => except[:prefix],
		:sender_address => except[:sender],
		:exception_recipients => except[:recipients],
		:ignore_crawlers      => %w{Googlebot bingbot AhrefsBot JikeSpider}
  }
end