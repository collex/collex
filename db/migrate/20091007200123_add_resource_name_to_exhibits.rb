class AddResourceNameToExhibits < ActiveRecord::Migration
  def self.up
    add_column :exhibits, :resource_name, :string
  end

  def self.down
    remove_column :exhibits, :resource_name
  end
end
