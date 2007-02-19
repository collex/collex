class AddApprovalBinary < ActiveRecord::Migration
  def self.up
  add_column(:tasks, :isApproved, :boolean, :default => false)
  end

  def self.down
  end
end
