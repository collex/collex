class AddBadgeToExhibits < ActiveRecord::Migration
  def self.up
    add_column :exhibits, :badge_id, :decimal
  end

  def self.down
    remove_column :exhibits, :badge_id
  end
end
