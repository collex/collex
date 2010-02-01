class RemoveFacultyFromGroups < ActiveRecord::Migration
  def self.up
    remove_column :groups, :faculty_names
  end

  def self.down
    add_column :groups, :faculty_names, :text
  end
end
