class AddBadgeToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :badge_id, :decimal
  end

  def self.down
    remove_column :groups, :badge_id
  end
end
