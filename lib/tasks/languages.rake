##########################################################################
# Copyright 2012 Applied Research in Patacriticism and the University of Virginia
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

namespace :languages do
  require 'csv'

  desc "Add languages to DB (file=path_to_file)"
  task :add => :environment do
    path = ENV['file']
    if path.blank?
      puts "Usage: rake languages:add file=path"
      return
    end

    file = File.open(path, 'r')
    file.lines.each { |line|
      values = line.split(/\|/)
      if values.length >= 5
        # assumes file is in the format alpha-3,alpha-3(t),alpha-2,English,French
        puts "#{values[0]},#{values[2]},#{values[3]}"
        alpha3 = values[0]
        alpha2 = values[2].empty? ? nil : values[2]
        english_name = values[3]
        lang = IsoLanguage.new(:alpha3 => alpha3, :alpha2 => alpha2, :english_name => english_name)
        lang.save()
      end
    }

  end
end