class AddVisibleUrlToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :visible_url, :string
  end

  def self.down
    remove_column :groups, :visible_url
  end
end
