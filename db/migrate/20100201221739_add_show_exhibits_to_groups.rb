class AddShowExhibitsToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :show_exhibits, :string
  end

  def self.down
    remove_column :groups, :show_exhibits
  end
end
