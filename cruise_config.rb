# Project-specific configuration for CruiseControl.rb
# This file is over-ridden by a file of the same name in CC's project dir

ENV['RAILS_ENV'] = 'test'

Project.configure do |project|
  
  # Send email notifications about broken and fixed builds to email1@your.site, email2@your.site (default: send to nobody)
  project.email_notifier.emails = ['technologies@nines.org']

  project.email_notifier.from = 'technologies@nines.org'

  # Build the project by invoking rake task 'custom'
  project.rake_task = 'cruise'

  # Build the project by invoking shell script "build_my_app.sh". Keep in mind that when the script is invoked, current working directory is 
  # [cruise]/projects/your_project/work, so if you do not keep build_my_app.sh in version control, it should be '../build_my_app.sh' instead
  # project.build_command = 'build_my_app.sh'

  # Ping Subversion for new revisions every 5 minutes (default: 30 seconds)
  project.scheduler.polling_interval = 1.minutes

end