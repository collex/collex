##########################################################################
# Copyright 2013 Applied Research in Patacriticism and the University of Virginia
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

namespace :bootstrap do
	desc "Set up the database with the minimum required (arg: URL of catalog)"
	task :globals, [:url] => :environment do |t, args|
		url = args.url
		rec = Setup.find_by_key('site_solr_url')
		if rec.present?
			rec.value = url
			save!
		else
			Setup.create!({ key: 'site_solr_url', value: url })
		end
	end
end
