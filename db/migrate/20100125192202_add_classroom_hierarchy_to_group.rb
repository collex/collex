class AddClassroomHierarchyToGroup < ActiveRecord::Migration
  def self.up
    add_column :groups, :university, :string
    add_column :groups, :faculty_names, :text
    add_column :groups, :course_name, :string
    add_column :groups, :course_mnemonic, :string
  end

  def self.down
    remove_column :groups, :course_mnemonic
    remove_column :groups, :course_name
    remove_column :groups, :faculty_names
    remove_column :groups, :university
  end
end
