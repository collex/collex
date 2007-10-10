##########################################################################
# Copyright 2007 Applied Research in Patacriticism and the University of Virginia
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


# Cruise Control custom task: CC will run this task by default, or we can call it in cruise_config.rb.

desc 'custom cruise control task'
task :cruise do
  Rake::Task["db:migrate"].invoke rescue got_error = true
  Rake::Task["db:test:purge"].invoke rescue got_error = true
  Rake::Task["test"].invoke rescue got_error = true
  Rake::Task["spec"].invoke rescue got_error = true

  raise "Test failures" if got_error
end  
