class AddNotificationsToGroupsusers < ActiveRecord::Migration
  def self.up
    add_column :groups_users, :notifications, :string
  end

  def self.down
    remove_column :groups_users, :notifications
  end
end
