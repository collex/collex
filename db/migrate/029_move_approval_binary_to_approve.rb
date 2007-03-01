class MoveApprovalBinaryToApprove < ActiveRecord::Migration
  def self.up
	add_column(:titles, :isApproved, :boolean, :default => false)
  end

  def self.down
  remove_column(:tasks, :isApproved, :boolean, :default => false)
  end
end
