Setup.init_smtp()

# config/initializers/setup_mail.rb

ActionMailer::Base.default_url_options[:host] = SITE_SPECIFIC['smtp_settings']['return_path']
#Mail.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?
