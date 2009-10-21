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

class AddSitesTable < ActiveRecord::Migration
  def self.up
    create_table :sites, :force => false do |t|
      t.column :code, :string
      t.column :url, :string
      t.column :description, :string
      t.column :thumbnail, :string
    end
    
#    initial_archives_yaml = <<-YAML
#rossetti:
#   url: http://www.rossettiarchive.org
#   description: The Rossetti Archive
#
#swinburne:
#   url: http://www.letrs.indiana.edu/swinburne
#   description: The Swinburne Project
#
#poetess:
#   url: http://www.orgs.muohio.edu/womenpoets/poetess/
#   description: The Poetess Archive
#
#rc:
#   url: http://www.rc.umd.edu/
#   description: Romantic Circles Praxis
#
#whitbib:
#   url: http://www.whitmanarchive.org/bibliography/
#   description: Whitman Bibliography
#
#chesnutt:
#   url: http://www.chesnuttarchive.org
#   description: Chesnutt Archive
#
#bwrp:
#    url: http://digital.lib.ucdavis.edu/projects/bwrp/
#    description: British Women Romantic Poets
#
#bierce:
#    url: http://www.ambrosebierce.org/main.html
#    description: The Ambrose Bierce Project
#
#victbib:
#    url: http://www.letrs.indiana.edu/web/v/victbib
#    description: Victorian Studies Bibliography
#YAML
#
#  initial_archives = YAML.load(initial_archives_yaml)
#
#  write "Loading initial archives..."
#  initial_archives.each do |site_name, site_data|
#    Site.create :code => site_name, :description => site_data['description'], :url => site_data['url']
#  end
#  write "done loading initial archives."
    
  end

  def self.down
    drop_table :sites
  end
end

