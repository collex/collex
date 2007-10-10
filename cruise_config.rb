##########################################################################
# Copyright 2007 Applied Research in Patacriticism
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################

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