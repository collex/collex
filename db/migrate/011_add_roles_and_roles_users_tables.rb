class AddRolesAndRolesUsersTables < ActiveRecord::Migration
  class Role < ActiveRecord::Base; end
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
  end
  
  def self.down
    drop_table :roles
    drop_table :roles_users
  end
end
