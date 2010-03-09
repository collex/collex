class AddFromToEmailWaiting < ActiveRecord::Migration
  def self.up
    add_column :email_waitings, :from_name, :string
    add_column :email_waitings, :from_email, :string
    add_column :email_waitings, :to_name, :string
  end

  def self.down
    remove_column :email_waitings, :to_name
    remove_column :email_waitings, :from_email
    remove_column :email_waitings, :from_name
  end
end
