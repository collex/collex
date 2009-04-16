class AddAliasToExhibit < ActiveRecord::Migration
  def self.up
    add_column :exhibits, :alias_id, :decimal
  end

  def self.down
    remove_column :exhibits, :alias_id
  end
end
