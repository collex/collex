class AddEditorColumnToUser < ActiveRecord::Migration
  def self.up
  add_column(:users, :isEditor, :boolean)
  end

  def self.down
  end
end
