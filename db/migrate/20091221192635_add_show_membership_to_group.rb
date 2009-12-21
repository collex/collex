class AddShowMembershipToGroup < ActiveRecord::Migration
  def self.up
    add_column :groups, :show_membership, :boolean
  end

  def self.down
    remove_column :groups, :show_membership
  end
end
