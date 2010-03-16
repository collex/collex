class AddSuffixToEmailWaitings < ActiveRecord::Migration
  def self.up
    add_column :email_waitings, :suffix, :string
  end

  def self.down
    remove_column :email_waitings, :suffix
  end
end
