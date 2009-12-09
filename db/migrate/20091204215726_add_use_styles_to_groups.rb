class AddUseStylesToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :use_styles, :decimal
  end

  def self.down
    remove_column :groups, :use_styles
  end
end
