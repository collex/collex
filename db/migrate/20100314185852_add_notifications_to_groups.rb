class AddNotificationsToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :notifications, :string
  end

  def self.down
    remove_column :groups, :notifications
  end
end
