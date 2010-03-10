class AddReturnUrlToEmailWaiting < ActiveRecord::Migration
  def self.up
    add_column :email_waitings, :return_url, :string
  end

  def self.down
    remove_column :email_waitings, :return_url
  end
end
