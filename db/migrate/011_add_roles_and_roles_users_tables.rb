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

class AddRolesAndRolesUsersTables < ActiveRecord::Migration
  class Role < ActiveRecord::Base; end
  class RolesUsers < ActiveRecord::Base; end
	
  def self.up
    create_table :roles do |t|
      t.column :name, :string
    end
    create_table :roles_users, :id => false do |t|
      t.column :role_id, :integer
      t.column :user_id, :integer
    end
    Role.create :name => "admin", :id => 1
    Role.create :name => "editor", :id => 2

		# now, create one user as an administrator, so they can bootstrap the system.
		User.create_user('admin', 'password', '')
		admin = User.find_by_username('admin')
		RolesUsers.create(:role_id => 1, :user_id => admin.id)
  end
  
  def self.down
    drop_table :roles
    drop_table :roles_users
  end
end
