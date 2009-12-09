class AddGroupIdToExhibits < ActiveRecord::Migration
  def self.up
    add_column :exhibits, :group_id, :decimal
  end

  def self.down
    remove_column :exhibits, :group_id
  end
end
