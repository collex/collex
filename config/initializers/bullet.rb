Collex::Application.config.after_initialize do
	# If the Bullet gem is included, this will initialize it and cause it to show inefficiency messages.
	if defined?(Bullet) == 'constant'
		Bullet.enable = true
		Bullet.alert = true
		Bullet.bullet_logger = true
		Bullet.rails_logger = true
	end
end
